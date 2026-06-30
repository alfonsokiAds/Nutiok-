class RecipeData {
  static const List<Map<String, dynamic>> defaultRecipes = [
    {
      "id": "1",
      "name": "Avena con Frutos Rojos",
      "description": "Un desayuno energético y lleno de fibra.",
      "category": "desayuno",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "1 taza de avena",
        "1/2 taza de leche",
        "Arándanos",
        "Miel"
      ],
      "steps": [
        "Calienta la leche.",
        "Agrega la avena y mezcla.",
        "Sirve con frutos."
      ],
      "calories": 250.0,
      "protein": 8.0,
      "carbs": 45.0,
      "fat": 5.0,
      "image_url":
          "https://images.unsplash.com/photo-1517673132405-a56a62b18caf"
    },
    {
      "id": "2",
      "name": "Ensalada de Pollo y Aguacate",
      "description": "Almuerzo ligero y rico en proteínas.",
      "category": "almuerzo",
      "difficulty": "media",
      "preparation_time": 20,
      "servings": 2,
      "ingredients": ["Pechuga de pollo", "Aguacate", "Lechuga", "Tomate"],
      "steps": [
        "Cocina el pollo.",
        "Corta los vegetales.",
        "Mezcla todo con limón."
      ],
      "calories": 350.0,
      "protein": 25.0,
      "carbs": 12.0,
      "fat": 18.0,
      "image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
    }
  ];
}
