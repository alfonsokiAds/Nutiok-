/// Recetas precargadas para NUTIOK
/// Datos locales que se pueden usar sin conexion a internet
class RecipeData {
  static List<Map<String, dynamic>> get defaultRecipes => [
    {
      'id': '1',
      'name': 'Avena con Frutas',
      'description': 'Desayuno energico y nutritivo con avena, frutas frescas y miel.',
      'category': 'desayuno',
      'difficulty': 'facil',
      'preparation_time': 10,
      'servings': 2,
      'calories': 280,
      'protein': 8.5,
      'carbs': 45.0,
      'fat': 6.2,
      'ingredients': [
        '1 taza de avena en hojuelas',
        '1 taza de leche',
        '1 banana madura',
        '1/2 taza de fresas',
        '1 cucharada de miel',
        'Canela al gusto',
        '1 cucharada de nueces'
      ],
      'steps': [
        'Calienta la leche en una olla a fuego medio.',
        'Agrega la avena y cocina por 5 minutos revolviendo.',
        'Sirve en un tazón y agrega la banana en rodajas.',
        'Decora con fresas, nueces y un toque de canela.',
        'Agrega miel al gusto y sirve caliente.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=500'
    },
    {
      'id': '2',
      'name': 'Ensalada Cesar Estudiantil',
      'description': 'Ensalada completa y economica ideal para el almuerzo universitario.',
      'category': 'almuerzo',
      'difficulty': 'facil',
      'preparation_time': 15,
      'servings': 2,
      'calories': 320,
      'protein': 18.0,
      'carbs': 22.0,
      'fat': 15.0,
      'ingredients': [
        '2 tazas de lechuga romana',
        '1 pechuga de pollo cocida y desmenuzada',
        '1/2 taza de crutones',
        '2 cucharadas de queso parmesano',
        '1 tomate en rodajas',
        'Aderezo Cesar (3 cucharadas)'
      ],
      'steps': [
        'Lava y corta la lechuga en trozos grandes.',
        'Coloca la lechuga como base en un plato grande.',
        'Agrega el pollo desmenuzado sobre la lechuga.',
        'Incorpora los crutones y el tomate.',
        'Espolvorea queso parmesano y aderezo al gusto.',
        'Mezcla bien antes de servir.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=500'
    },
    {
      'id': '3',
      'name': 'Wrap de Pollo y Verduras',
      'description': 'Wrap rapido y nutritivo perfecto para llevar entre clases.',
      'category': 'almuerzo',
      'difficulty': 'facil',
      'preparation_time': 20,
      'servings': 2,
      'calories': 380,
      'protein': 25.0,
      'carbs': 35.0,
      'fat': 12.0,
      'ingredients': [
        '2 tortillas de harina integral',
        '1 pechuga de pollo cocida',
        '1/2 aguacate',
        '1 zanahoria rallada',
        '1/4 taza de lechuga picada',
        '2 cucharadas de mayonesa ligera',
        'Sal y pimienta al gusto'
      ],
      'steps': [
        'Cocina y desmenuza la pechuga de pollo.',
        'Mezcla el pollo con mayonesa, sal y pimienta.',
        'Calienta ligeramente las tortillas.',
        'Distribuye la mezcla de pollo sobre cada tortilla.',
        'Agrega aguacate en rodajas, zanahoria y lechuga.',
        'Enrolla los wraps y corta por la mitad. Sirve.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500'
    },
    {
      'id': '4',
      'name': 'Pasta Mediterranea',
      'description': 'Pasta con vegetales frescos y aderezo ligero de la dieta mediterranea.',
      'category': 'almuerzo',
      'difficulty': 'media',
      'preparation_time': 30,
      'servings': 4,
      'calories': 420,
      'protein': 14.0,
      'carbs': 55.0,
      'fat': 16.0,
      'ingredients': [
        '250g de pasta penne integral',
        '2 tomates maduros',
        '1/2 cebolla morada',
        '1 pimenton rojo',
        'Aceite de oliva extra virgen',
        '2 dientes de ajo',
        'Albahaca fresca',
        'Queso parmesano rallado',
        'Sal y pimienta'
      ],
      'steps': [
        'Cocina la pasta en agua hirviendo con sal hasta que este al dente.',
        'Corta los tomates, la cebolla y el pimenton en juliana.',
        'Sofrie el ajo picado en aceite de oliva a fuego medio.',
        'Agrega los vegetales y cocina por 5-7 minutos.',
        'Incorpora la pasta cocida y mezcla bien.',
        'Sirve con albahaca fresca y queso parmesano.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500'
    },
    {
      'id': '5',
      'name': 'Bowl de Arroz con Pollo',
      'description': 'Bowl nutritivo con arroz integral, pollo y vegetales salteados.',
      'category': 'almuerzo',
      'difficulty': 'media',
      'preparation_time': 35,
      'servings': 2,
      'calories': 450,
      'protein': 30.0,
      'carbs': 50.0,
      'fat': 10.0,
      'ingredients': [
        '1 taza de arroz integral cocido',
        '1 pechuga de pollo',
        '1 zanahoria',
        '1/2 brocoli',
        '1/2 pimenton rojo',
        '2 cucharadas de salsa de soya',
        '1 cucharada de aceite de sésamo',
        'Semillas de sésamo'
      ],
      'steps': [
        'Cocina el arroz integral siguiendo las instrucciones del paquete.',
        'Corta el pollo en tiras y sazona con salsa de soya.',
        'Saltea el pollo en aceite de sésamo hasta que este dorado.',
        'Agrega los vegetales cortados y saltea 5 minutos.',
        'Arma el bowl con arroz como base, pollo y vegetales encima.',
        'Decora con semillas de sésamo y sirve caliente.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500'
    },
    {
      'id': '6',
      'name': 'Smoothie Verde Energizante',
      'description': 'Bebida nutritiva para empezar el dia con energia y vitaminas.',
      'category': 'desayuno',
      'difficulty': 'facil',
      'preparation_time': 5,
      'servings': 1,
      'calories': 180,
      'protein': 5.0,
      'carbs': 35.0,
      'fat': 2.0,
      'ingredients': [
        '1 taza de espinaca fresca',
        '1 banana congelada',
        '1/2 taza de mango congelado',
        '1 taza de leche de almendras',
        '1 cucharada de semillas de chia',
        'Miel al gusto'
      ],
      'steps': [
        'Coloca todos los ingredientes en la licuadora.',
        'Licua a velocidad alta por 1-2 minutos.',
        'Verifica la consistencia, agrega leche si es necesario.',
        'Sirve en un vaso y agrega semillas de chia.',
        'Endulza con miel si lo deseas. Sirve inmediatamente.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=500'
    },
    {
      'id': '7',
      'name': 'Tostadas de Aguacate y Huevo',
      'description': 'Desayuno con proteinas y grasas saludables para concentrarse en clase.',
      'category': 'desayuno',
      'difficulty': 'facil',
      'preparation_time': 10,
      'servings': 1,
      'calories': 320,
      'protein': 16.0,
      'carbs': 28.0,
      'fat': 18.0,
      'ingredients': [
        '2 rebanadas de pan integral',
        '1 aguacate maduro',
        '2 huevos',
        'Sal y pimienta',
        '1 cucharadita de aceite de oliva',
        'Chile en hojuelas (opcional)',
        'Jugo de limon'
      ],
      'steps': [
        'Tuesta las rebanadas de pan integral.',
        'Machaca el aguacate con tenedor, agrega limon, sal y pimienta.',
        'Cocina los huevos al gusto (fritos o pochados).',
        'Unta el aguacate sobre las tostadas.',
        'Coloca los huevos encima del aguacate.',
        'Decora con chile en hojuelas y sirve.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500'
    },
    {
      'id': '8',
      'name': 'Sopa de Lentejas',
      'description': 'Sopa reconfortante y economica, rica en hierro y proteinas.',
      'category': 'cena',
      'difficulty': 'facil',
      'preparation_time': 40,
      'servings': 4,
      'calories': 220,
      'protein': 15.0,
      'carbs': 35.0,
      'fat': 3.0,
      'ingredients': [
        '1 taza de lentejas',
        '1 zanahoria',
        '1 papa mediana',
        '1/2 cebolla',
        '2 dientes de ajo',
        '1 tallo de celeri',
        'Cilantro fresco',
        'Sal y comino al gusto'
      ],
      'steps': [
        'Lava las lentejas y remojalas 30 minutos si es necesario.',
        'Pica todas las verduras en trozos pequenos.',
        'Sofrie la cebolla y el ajo en una olla con aceite.',
        'Agrega la zanahoria, la papa y el celeri. Cocina 3 minutos.',
        'Anade las lentejas y agua suficiente (3 tazas).',
        'Cocina a fuego bajo por 25-30 minutos hasta que este suave.',
        'Condimenta con sal y comino. Sirve con cilantro fresco.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=500'
    },
    {
      'id': '9',
      'name': 'Quesadillas de Pollo',
      'description': 'Cena rapida y deliciosa con pollo, queso y verduras.',
      'category': 'cena',
      'difficulty': 'facil',
      'preparation_time': 15,
      'servings': 2,
      'calories': 380,
      'protein': 22.0,
      'carbs': 30.0,
      'fat': 18.0,
      'ingredients': [
        '4 tortillas de harina',
        '1 pechuga de pollo cocida y desmenuzada',
        '1 taza de queso mozzarella rallado',
        '1/2 pimenton verde',
        '1/4 taza de cebolla picada',
        '1 cucharada de aceite'
      ],
      'steps': [
        'Calienta una sarten a fuego medio con aceite.',
        'Coloca una tortilla en la sarten.',
        'Agrega queso, pollo, pimenton y cebolla sobre la mitad.',
        'Dobla la tortilla por la mitad y cocina 2 minutos por lado.',
        'Repite con las tortillas restantes.',
        'Corta en triangulos y sirve con guacamole.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1618040996337-56904b7850b9?w=500'
    },
    {
      'id': '10',
      'name': 'Granola con Yogurt',
      'description': 'Snack saludable y energico para estudiar o entre comidas.',
      'category': 'snack',
      'difficulty': 'facil',
      'preparation_time': 5,
      'servings': 1,
      'calories': 250,
      'protein': 10.0,
      'carbs': 38.0,
      'fat': 8.0,
      'ingredients': [
        '1 taza de yogurt natural',
        '1/2 taza de granola',
        '1/4 taza de arandanos',
        '1 cucharada de miel',
        '1 cucharada de semillas de girasol'
      ],
      'steps': [
        'Sirve el yogurt en un tazón.',
        'Agrega la granola sobre el yogurt.',
        'Decora con arandanos frescos.',
        'Espolvorea semillas de girasol.',
        'Agrega miel al gusto y sirve.'
      ],
      'image_url': 'https://images.unsplash.com/photo-1571748982800-fa51082c2224?w=500'
    }
  ];
}
