/// Catálogo oficial de recetas saludables para NUTIOK
/// Extraídas y adaptadas del manual 'AFA - Desayunos y Meriendas Saludables'
class RecipeData {
  static const List<Map<String, dynamic>> defaultRecipes = [
    // -------------------------------------------------------------
    // DESAYUNOS
    // -------------------------------------------------------------
    {
      "id": "afa_1",
      "name": "Tostada de Aguacate con Queso Fresco",
      "description": "Desayuno clásico, rico en grasas saludables y proteína ligera.",
      "category": "desayuno",
      "difficulty": "facil",
      "preparation_time": 5,
      "servings": 1,
      "ingredients": [
        "1 tostada de pan integral",
        "1/2 aguacate maduro",
        "1 tarrina de queso fresco (tipo Burgos)",
        "1 cucharadita de pipas de girasol peladas"
      ],
      "steps": [
        "Corta el aguacate en trozos o láminas iguales.",
        "Corta el queso fresco en rodajas.",
        "Coloca el aguacate sobre la base de la tostada integral.",
        "Pon el queso fresco por encima del aguacate.",
        "Espolvorea las pipas peladas por encima y disfruta."
      ],
      "calories": 220.0,
      "protein": 7.5,
      "carbs": 18.0,
      "fat": 12.0,
      "image_url": "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500"
    },
    {
      "id": "afa_2",
      "name": "Batido de Plátano, Arándanos y Avena",
      "description": "Batido saciante y lleno de antioxidantes para empezar el día con energía.",
      "category": "desayuno",
      "difficulty": "facil",
      "preparation_time": 15,
      "servings": 1,
      "ingredients": [
        "40g de plátano maduro",
        "100g de arándanos frescos",
        "60g de avena molida",
        "250 ml de leche semidesnatada (o bebida vegetal)"
      ],
      "steps": [
        "Pelar el plátano y cortarlo en rodajas.",
        "Dejar la avena en remojo durante 15 minutos en un poco de agua o leche.",
        "Colocar en la batidora el plátano, los arándanos, la avena escurrida y la leche.",
        "Batir a máxima potencia hasta conseguir una textura cremosa y homogénea."
      ],
      "calories": 280.0,
      "protein": 9.0,
      "carbs": 52.0,
      "fat": 4.5,
      "image_url": "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=500"
    },
    {
      "id": "afa_3",
      "name": "Porridge de Avena y Plátano",
      "description": "Gachas calientes de avena, reconfortantes y con energía de liberación lenta.",
      "category": "desayuno",
      "difficulty": "facil",
      "preparation_time": 15,
      "servings": 1,
      "ingredients": [
        "100 g de copos de avena",
        "250 ml de agua",
        "250 ml de leche de arroz o avena",
        "1/2 plátano maduro en rodajas",
        "Canela en polvo al gusto"
      ],
      "steps": [
        "Calienta los copos de avena en un cazo junto con el agua y la leche de arroz.",
        "Cuece a fuego medio removiendo constantemente con cuchara de madera.",
        "Cuando haya espesado (aprox. 10 minutos), retira del fuego y deja reposar tapado 5 minutos.",
        "Vierte en un bol, añade las rodajas de plátano por encima y espolvorea canela."
      ],
      "calories": 290.0,
      "protein": 8.0,
      "carbs": 55.0,
      "fat": 4.0,
      "image_url": "https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=500"
    },
    {
      "id": "afa_4",
      "name": "Bocadillo de Tomate, Aguacate y Huevo Duro",
      "description": "Desayuno completo con carbohidratos complejos, proteína de alto valor y grasas saludables.",
      "category": "desayuno",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral tamaño palma",
        "1/2 aguacate maduro en láminas",
        "1 tomate maduro en rodajas",
        "1 huevo cocido duro en rodajas",
        "Pizca de sal y orégano"
      ],
      "steps": [
        "Tuesta ligeramente el panecillo integral.",
        "Coloca una base de rodajas de tomate con una pizca de sal.",
        "Distribuye las láminas de aguacate maduro.",
        "Corona con el huevo cocido en rodajas, espolvorea orégano y cierra el bocadillo."
      ],
      "calories": 320.0,
      "protein": 14.0,
      "carbs": 28.0,
      "fat": 16.0,
      "image_url": "https://images.unsplash.com/photo-1525351484163-7529414344d8?w=500"
    },

    // -------------------------------------------------------------
    // ALMUERZOS
    // -------------------------------------------------------------
    {
      "id": "afa_5",
      "name": "Burrito con Guacamole Saludable",
      "description": "Almuerzo rápido para universitarios, fresco y nutritivo.",
      "category": "almuerzo",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "2 tortitas o tortillas de maíz",
        "1/2 aguacate maduro",
        "4 tomates cherry picados",
        "1/2 limón (zumo)",
        "Brotes verdes y cilantro picado",
        "Sal y pimienta al gusto"
      ],
      "steps": [
        "Prepara un guacamole casero machacando el aguacate con los tomates cherry, zumo de limón, cilantro, sal y pimienta.",
        "Calienta levemente las tortitas de maíz en sartén.",
        "Unta cada tortita con el guacamole y coloca brotes verdes al gusto.",
        "Enrolla firmemente los burritos y córtalos por la mitad."
      ],
      "calories": 310.0,
      "protein": 8.0,
      "carbs": 32.0,
      "fat": 15.0,
      "image_url": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500"
    },
    {
      "id": "afa_6",
      "name": "Bocadillo de Pollo a la Plancha y Aguacate",
      "description": "Rico en proteína magra, saciante y fácil de transportar al campus.",
      "category": "almuerzo",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral",
        "80 g de pechuga de pollo a la plancha en tiras",
        "1/2 aguacate machacado con unas gotas de limón",
        "Hojas de rúcula o lechuga fresca"
      ],
      "steps": [
        "Cocina la pechuga de pollo a la plancha con una gota de aceite, sal y pimienta.",
        "Unta el pan integral con el aguacate machacado con limón.",
        "Coloca las tiras de pechuga de pollo caliente y la rúcula fresca.",
        "Cierra el bocadillo y acompaña con una botella de agua."
      ],
      "calories": 350.0,
      "protein": 26.0,
      "carbs": 27.0,
      "fat": 13.0,
      "image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500"
    },
    {
      "id": "afa_7",
      "name": "Bocadillo de Atún con Pimiento del Piquillo",
      "description": "Proteína omega 3 y fibra en un almuerzo exprés sin necesidad de encender la estufa.",
      "category": "almuerzo",
      "difficulty": "facil",
      "preparation_time": 5,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral",
        "1 lata de atún al natural bien escurrido",
        "2 pimientos del piquillo en tiras",
        "Unas gotas de aceite de oliva virgen extra"
      ],
      "steps": [
        "Abre el pan integral por la mitad.",
        "Desmenuza el atún al natural escurrido de manera homogénea.",
        "Coloca las tiras de pimiento del piquillo y aliña con gotas de aceite de oliva."
      ],
      "calories": 290.0,
      "protein": 24.0,
      "carbs": 30.0,
      "fat": 5.0,
      "image_url": "https://images.unsplash.com/photo-1509722747041-616f39b57569?w=500"
    },
    {
      "id": "afa_8",
      "name": "Bocadillo Vegetal con Espárragos y Huevo",
      "description": "Opción vegetariana fresca y equilibrada con vegetales crujientes.",
      "category": "almuerzo",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral",
        "1 huevo duro en rodajas",
        "2 espárragos blancos",
        "1 tomate maduro en rodajas",
        "Brotes tiernos de lechuga",
        "Aceite de oliva virgen extra y sal"
      ],
      "steps": [
        "Lava y corta el tomate en rodajas finas.",
        "Dispone una cama de brotes tiernos, el tomate y los espárragos bien escurridos.",
        "Agrega las rodajas de huevo duro, aliña con un hilo de aceite y una pizca de sal."
      ],
      "calories": 280.0,
      "protein": 13.0,
      "carbs": 32.0,
      "fat": 9.0,
      "image_url": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500"
    },

    // -------------------------------------------------------------
    // CENAS
    // -------------------------------------------------------------
    {
      "id": "afa_9",
      "name": "Tortitas de Avena con Tomate y Requesón",
      "description": "Cena liviana de fácil digestión, ideal para descansar bien antes de los exámenes.",
      "category": "cena",
      "difficulty": "facil",
      "preparation_time": 15,
      "servings": 1,
      "ingredients": [
        "2 claras de huevo",
        "20 g de copos de avena finos",
        "1/2 cdta de levadura en polvo",
        "1/2 tomate picado en daditos",
        "40 g de requesón bajo en sal",
        "Pizca de sal y pimienta recién molida"
      ],
      "steps": [
        "Bate la avena con las claras de huevo, la levadura y una pizca de sal.",
        "Calienta una sartén antiadherente y vierte pequeñas porciones de la mezcla.",
        "Cocina 1-2 minutos por lado hasta que estén doradas y retira.",
        "Unta las tortitas con el requesón, coloca encima el tomate picado y unas gotas de aceite."
      ],
      "calories": 210.0,
      "protein": 16.0,
      "carbs": 19.0,
      "fat": 6.5,
      "image_url": "https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=500"
    },
    {
      "id": "afa_10",
      "name": "Bocadillo de Berenjena a la Plancha con Queso Fresco",
      "description": "Cena caliente, vegetal y ligera con queso atemperado sobre berenjena.",
      "category": "cena",
      "difficulty": "facil",
      "preparation_time": 12,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral",
        "3-4 rodajas de berenjena",
        "50 g de queso fresco en lonchas",
        "1 cdta de aceite de oliva",
        "Orégano seco y sal"
      ],
      "steps": [
        "Pasa las rodajas de berenjena por la plancha con una gota de aceite hasta que estén tiernas.",
        "Abre el pan integral y coloca las rodajas de berenjena calientes.",
        "Intercala las lonchas de queso fresco para que se atempere suavemente.",
        "Espolvorea orégano y sirve caliente."
      ],
      "calories": 240.0,
      "protein": 12.0,
      "carbs": 29.0,
      "fat": 7.0,
      "image_url": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500"
    },
    {
      "id": "afa_11",
      "name": "Bocadillo de Hummus, Berenjena y Rúcula",
      "description": "Cena vegana repleta de fibra, minerales y proteína vegetal.",
      "category": "cena",
      "difficulty": "facil",
      "preparation_time": 10,
      "servings": 1,
      "ingredients": [
        "1 panecillo integral",
        "2 cucharadas soperas de hummus de garbanzo",
        "Rodajas de berenjena a la plancha",
        "Un puñado de hojas de rúcula fresca"
      ],
      "steps": [
        "Dora la berenjena en una sartén antiadherente con una pizca de sal.",
        "Unta generosamente ambas caras del pan integral con el hummus.",
        "Rellena con la berenjena asada y la rúcula fresca.",
        "Cierra y sirve."
      ],
      "calories": 260.0,
      "protein": 9.0,
      "carbs": 36.0,
      "fat": 8.0,
      "image_url": "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500"
    },

    // -------------------------------------------------------------
    // SNACKS / MERIENDAS
    // -------------------------------------------------------------
    {
      "id": "afa_12",
      "name": "Pudding de Chía y Mango",
      "description": "Merienda refrescante y saludable rica en ácidos grasos omega 3 y fibra soluble.",
      "category": "snack",
      "difficulty": "facil",
      "preparation_time": 15,
      "servings": 2,
      "ingredients": [
        "1/2 mango maduro",
        "50g de semillas de chía",
        "400ml de leche de coco (o bebida de almendras)"
      ],
      "steps": [
        "Mezcla las semillas de chía con la leche de coco y deja que se hidraten durante al menos 2 horas o desde la noche anterior.",
        "Pela el mango y corta un cuarto en daditos pequeños para decorar.",
        "Tritura el resto del mango hasta obtener un puré suave.",
        "En un vaso o copa, sirve la base de chía hidratada y corona con el puré y daditos de mango fresco."
      ],
      "calories": 260.0,
      "protein": 6.0,
      "carbs": 34.0,
      "fat": 11.0,
      "image_url": "https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=500"
    },
    {
      "id": "afa_13",
      "name": "Yogur Natural con Frutas y Chocolate Negro",
      "description": "Snack antioxidante perfecto para media tarde y calmar antojos dulces sanamente.",
      "category": "snack",
      "difficulty": "facil",
      "preparation_time": 5,
      "servings": 1,
      "ingredients": [
        "1 o 2 yogures naturales sin azúcar",
        "1 pieza de fruta de temporada (fresas, kiwi o plátano)",
        "2 onzas de chocolate negro (+70% cacao)"
      ],
      "steps": [
        "Lava y corta la fruta en bocados pequeños.",
        "Ralla las onzas de chocolate negro o pícalas finamente.",
        "En un tazón, vierte el yogur natural, incorpora la fruta y espolvorea el chocolate por encima."
      ],
      "calories": 190.0,
      "protein": 7.0,
      "carbs": 24.0,
      "fat": 6.0,
      "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500"
    },
    {
      "id": "afa_14",
      "name": "Galletas de Avena y Plátano Caseras",
      "description": "Galletas horneadas sin azúcar refinada ni harinas procesadas, ideales para llevar a clase.",
      "category": "snack",
      "difficulty": "facil",
      "preparation_time": 25,
      "servings": 4,
      "ingredients": [
        "150 g de copos de avena",
        "2 plátanos maduros",
        "1 cdta de aceite de semillas",
        "1 cdta de canela molida",
        "1 cdta de esencia de vainilla",
        "1 1/2 cda de miel"
      ],
      "steps": [
        "Pela los plátanos y machácalos con tenedor en un bol.",
        "Mézclalos con la avena, canela, vainilla, miel y el aceite hasta formar una pasta homogénea.",
        "Precalienta el horno a 180°C y coloca papel de horno en la bandeja.",
        "Reparte porciones con cuchara dándoles forma redonda y hornea durante 15 minutos hasta que estén doraditas.",
        "Deja enfriar antes de guardar en tu táper o lonchera."
      ],
      "calories": 160.0,
      "protein": 4.5,
      "carbs": 29.0,
      "fat": 3.2,
      "image_url": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500"
    }
  ];
}
