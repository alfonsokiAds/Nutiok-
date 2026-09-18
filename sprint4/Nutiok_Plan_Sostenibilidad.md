# Plan de Sostenibilidad - NUTIOK

## 1. Resumen Ejecutivo
Este documento define la estrategia para asegurar la viabilidad técnica, operativa y financiera de la aplicación **NUTIOK** a largo plazo, garantizando un servicio estable para los estudiantes de la Universidad de Cundinamarca Seccional Ubaté y futuras expansiones.

## 2. Sostenibilidad Técnica
Para mantener la aplicación funcionando de manera óptima en el futuro:
*   **Mantenimiento de Dependencias:** Realizar auditorías trimestrales de los paquetes de Flutter (pub.dev) para actualizar versiones mayores y corregir vulnerabilidades de seguridad.
*   **Optimización de Consultas:** Monitorear el rendimiento de la base de datos PostgreSQL en Supabase. Si la base de usuarios crece, se deben crear índices adicionales para las consultas del horario y recordatorios.
*   **Monitoreo de APIs Externas:** Mantener control estricto sobre el uso de la API de Google Maps para evitar superar la capa gratuita. En el futuro, evaluar alternativas Open Source si los costos incrementan.

## 3. Sostenibilidad Operativa y Escalabilidad
*   **Infraestructura en la Nube:** Actualmente Supabase opera en el *Free Tier*. Al superar los límites de almacenamiento o usuarios concurrentes, se debe planificar la transición a un plan de pago (Plan Pro) que garantice el uptime de la app.
*   **Soporte a Usuarios:** Implementar un canal de *feedback* dentro de la app para que los estudiantes reporten bugs o sugieran funcionalidades.

## 4. Sostenibilidad Financiera (Modelo de Negocio)
Para poder sufragar los gastos de la infraestructura y el mantenimiento en el mediano plazo, se proponen las siguientes estrategias:
*   **Alianzas Locales:** Integrar en el módulo de Mapas (Sprint 4) opciones de restaurantes patrocinados de Ubaté, permitiendo a los locales pagar una pequeña suscripción para aparecer como "Restaurante Destacado" a los usuarios de la Universidad.
*   **Funciones Premium (Freemium):** Mantener el núcleo de la app (gestión de horario y recordatorios básicos) gratis. Ofrecer características premium como planes nutricionales personalizados o integración con calendarios externos por un pequeño pago único o suscripción.
*   **Soporte Institucional:** Buscar patrocinio o alianzas con la misma universidad (área de bienestar universitario) para promocionar la app y obtener apoyo económico.
