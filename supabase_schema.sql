/// Esquema SQL para la base de datos de NUTIOK en Supabase
/// 
/// Instrucciones:
/// 1. Vaya a su proyecto en Supabase Dashboard
/// 2. Navegue a SQL Editor
/// 3. Copie y ejecute cada seccion como consultas separadas
///
/// Este esquema crea todas las tablas necesarias para la aplicacion
/// con las relaciones, restricciones y policies de seguridad (RLS)

-- ========================================
-- TABLA: profiles (Perfiles de usuario)
-- ========================================
-- Almacena informacion adicional del usuario
-- Se crea automaticamente al registrarse via trigger

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    age INTEGER CHECK (age >= 10 AND age <= 120),
    weight DECIMAL(5,2) CHECK (weight >= 20 AND weight <= 300),
    height DECIMAL(5,2) CHECK (height >= 50 AND height <= 250),
    bmi DECIMAL(5,2),
    gender TEXT CHECK (gender IN ('masculino', 'femenino', 'otro')),
    dietary_goal TEXT CHECK (dietary_goal IN ('mantener_peso', 'bajar_peso', 'subir_peso')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indice para busqueda rapida por email
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- RLS: Solo el usuario puede ver y editar su propio perfil
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Trigger para crear perfil automaticamente al registrar usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();


-- ========================================
-- TABLA: notes (Notas alimentarias)
-- ========================================
-- HU-3: Crear y guardar notas sobre comidas

CREATE TABLE IF NOT EXISTS notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    meal_type TEXT CHECK (meal_type IN ('desayuno', 'almuerzo', 'cena', 'snack', 'otro')),
    meal_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_meal_date ON notes(user_id, meal_date DESC);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notes"
    ON notes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notes"
    ON notes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes"
    ON notes FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes"
    ON notes FOR DELETE
    USING (auth.uid() = user_id);


-- ========================================
-- TABLA: reminders (Recordatorios)
-- ========================================
-- HU-4: Recordatorios de horarios de comida

CREATE TABLE IF NOT EXISTS reminders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    time TIME NOT NULL,
    meal_type TEXT NOT NULL CHECK (meal_type IN ('desayuno', 'almuerzo', 'cena', 'snack')),
    is_active BOOLEAN DEFAULT TRUE,
    repeat_daily BOOLEAN DEFAULT TRUE,
    day_of_week INTEGER CHECK (day_of_week IS NULL OR (day_of_week >= 1 AND day_of_week <= 7)),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON reminders(user_id);

ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reminders"
    ON reminders FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reminders"
    ON reminders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reminders"
    ON reminders FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reminders"
    ON reminders FOR DELETE
    USING (auth.uid() = user_id);


-- ========================================
-- TABLA: recipes (Recetas)
-- ========================================
-- HU-5: Consultar recetas saludables
-- Tabla publica (lectura para todos, admin escribe)

CREATE TABLE IF NOT EXISTS recipes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('desayuno', 'almuerzo', 'cena', 'snack')),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('facil', 'media', 'dificil')),
    preparation_time INTEGER NOT NULL,
    servings INTEGER DEFAULT 1,
    ingredients JSONB NOT NULL DEFAULT '[]'::jsonb,
    steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    image_url TEXT,
    calories DECIMAL(6,2),
    protein DECIMAL(5,2),
    carbs DECIMAL(5,2),
    fat DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipes_category ON recipes(category);

-- Las recetas son de lectura publica
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view recipes"
    ON recipes FOR SELECT
    USING (true);


-- ========================================
-- TABLA: favorites (Recetas favoritas)
-- ========================================

CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, recipe_id)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own favorites"
    ON favorites FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
    ON favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
    ON favorites FOR DELETE
    USING (auth.uid() = user_id);


-- ========================================
-- DATOS INICIALES: Recetas precargadas
-- ========================================
-- Se pueden insertar las recetas desde la app o manualmente

-- Ejemplo de insercion de receta:
-- INSERT INTO recipes (name, description, category, difficulty, preparation_time, servings, ingredients, steps, calories, protein, carbs, fat)
-- VALUES (
--     'Avena con Frutas',
--     'Desayuno energetico y nutritivo.',
--     'desayuno',
--     'facil',
--     10,
--     2,
--     '["1 taza de avena", "1 banana", "1/2 taza de fresas"]'::jsonb,
--     '["Calienta la leche.", "Agrega la avena.", "Sirve con frutas."]'::jsonb,
--     280, 8.5, 45.0, 6.2
-- );
