-- Mellali Scent: supprimer tous les produits de test
-- IMPORTANT : à exécuter seulement si la table products ne contient encore
-- aucun vrai produit que tu veux garder.

DELETE FROM public.products;

NOTIFY pgrst, 'reload schema';
