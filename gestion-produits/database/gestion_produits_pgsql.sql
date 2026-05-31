-- Schéma PostgreSQL pour gestion_produits
-- Adapté depuis le dump MySQL (gestion_produits.sql)
--
-- Différences principales vs MySQL :
--   AUTO_INCREMENT  → SERIAL (séquence automatique PostgreSQL)
--   ENGINE=InnoDB   → supprimé (pas de notion de moteur en PostgreSQL)
--   CHARSET=utf8mb3 → supprimé (UTF-8 par défaut en PostgreSQL)
--   LOCK/UNLOCK TABLES → supprimés (non supportés)
--   Les commentaires /*!...*/ MySQL → supprimés
--
-- La base de données est créée automatiquement par la variable POSTGRES_DB
-- Ce script crée uniquement les tables et insère les données

-- Suppression dans l'ordre des dépendances (FK : ressources → produits)
DROP TABLE IF EXISTS ressources CASCADE;
DROP TABLE IF EXISTS produits CASCADE;
DROP TABLE IF EXISTS utilisateurs CASCADE;

-- Table produits
CREATE TABLE produits (
    PRO_id      SERIAL       NOT NULL,
    PRO_lib     VARCHAR(200) NOT NULL,
    PRO_prix    DECIMAL(10,2) NOT NULL,
    PRO_description TEXT,
    PRIMARY KEY (PRO_id)
);

-- Table ressources (liée à produits par clé étrangère)
CREATE TABLE ressources (
    RE_id   SERIAL        NOT NULL,
    RE_type VARCHAR(100)  NOT NULL,
    RE_url  VARCHAR(1000) NOT NULL,
    RE_nom  VARCHAR(100)  DEFAULT NULL,
    PRO_id  INTEGER       NOT NULL,
    PRIMARY KEY (RE_id),
    CONSTRAINT ressources_produits_FK FOREIGN KEY (PRO_id) REFERENCES produits (PRO_id)
);

CREATE INDEX idx_ressources_produits ON ressources (PRO_id);

-- Table utilisateurs
CREATE TABLE utilisateurs (
    US_id       SERIAL       NOT NULL,
    US_login    VARCHAR(100) NOT NULL,
    US_password VARCHAR(100) NOT NULL,
    PRIMARY KEY (US_id),
    UNIQUE (US_login)
);

-- Données : produits
INSERT INTO produits (PRO_id, PRO_lib, PRO_prix, PRO_description) VALUES
(1, 'Pédales Shimano XT M8040 M/L', 74.99, 'Les pédales plates SHIMANO XT PD-M8040 sont destinées à un usage All Mountain/Enduro. Très solides grâce à leur axe en acier chromoly, elles se caractérisent notamment par leur plateforme concave, qui accueille 10 picots dévissables, qui favorisent le grip sous la semelle. Leur structure est également plus ouverte et dégagée, qui empêche la boue de s''accumuler.

Ces pédales XT Deore sont proposées ici en taille ML, mieux adaptée aux chaussures dont la pointure est comprise entre 43 et 48. '),
(2, 'Selle FIZIK ARIONE VERSUS Rails Kium', 59.99, 'Modèle confortable avant tout, la selle FIZIK Arione Versus possède un profil tout à fait plat et très long (300 mm) qui convient aux pratiquants justifiant d''une excellente souplesse vertébrale. Sa surface présente un canal central évidé, caractéristique des selles de la ligne Versus, qui permet de réduire les points de pression sur la zone périnéale.

L''Arione Versus présente des rails légers et résistants en matériau Kium, et une coque associant du carbone à du nylon, pour offrir un supplément de souplesse aux endroits où les cuisses entrent en contact avec la selle, durant la phase de pédalage.'),
(3, 'Chaussures VTT MAVIC CROSSMAX SL PRO THERMO Noir', 164.99, 'Les chaussures Cross Max SL Pro Thermo créées par la marque MAVIC plairont aux riders voulant profiter de leur vélo en hiver ! Elles offrent une protection optimale contre le froid et contre la pluie.'),
(4, 'Pack GPS GARMIN EDGE 1030 + Ceinture Cardio', 519.99, 'Le Pack GPS Edge 1030 plus la ceinture cardio de Garmin est fait pour les compétiteurs et les adeptes de performances.'),
(5, 'Fourche DVO SAPPHIRE 29', 549.99, 'Dérivée de la Diamond, la fourche DVO Sapphire 29" marque l''entrée de la marque californienne dans le segment des fourches Trail / All Mountain.');

-- Données : ressources
INSERT INTO ressources (RE_id, RE_type, RE_url, RE_nom, PRO_id) VALUES
(43, 'img', 'uploads/5-19b235d023eef2281304433f0d4438b6.jpg', NULL, 5),
(44, 'img', 'uploads/5-b02cbdbc96d5c9a20526763576f56a11.jpg', NULL, 5),
(45, 'img', 'uploads/5-8e258524bf0f2aae28647a1aa8a77a8c.jpg', NULL, 5),
(46, 'img', 'uploads/4-a21d716bdfda2004d50171559c4b1b92.jpg', NULL, 4),
(47, 'img', 'uploads/4-1cb57a6c1de5c2573679654054a2b3b0.jpg', NULL, 4),
(48, 'img', 'uploads/4-438b7f4eec56d20aca694793882909ac.jpg', NULL, 4),
(49, 'img', 'uploads/1-707116622e5d4fe50dfc6391af4a5421.jpg', NULL, 1),
(50, 'img', 'uploads/1-7f8aacccd9c522281c58e5eb90cbb6a8.jpg', NULL, 1),
(51, 'img', 'uploads/1-987e17d65fb62e5fece343304d7be827.jpg', NULL, 1),
(53, 'img', 'uploads/2-5dfd065b9d05455732d122cdc3b64e27.jpg', NULL, 2),
(54, 'img', 'uploads/2-7e38160b643cf0e21ff445c9594e77d7.jpg', NULL, 2),
(55, 'img', 'uploads/2-2228cc7d3b9f647bfa31dd4ebf0f3885.jpg', NULL, 2),
(60, 'img', 'uploads/3-c518a7a917d0c35dd1d46331b62f6df8.jpg', NULL, 3),
(61, 'img', 'uploads/3-f6f0e00161c27468b39bda23969b19a5.jpg', NULL, 3),
(62, 'img', 'uploads/3-2b2b730177e21ac71bcb8cda0359c34a.jpg', NULL, 3);

-- Données : utilisateurs (password = hash SHA-256 de "password")
INSERT INTO utilisateurs (US_id, US_login, US_password) VALUES
(1, 'admin', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8');

-- Réinitialisation des séquences après insertion avec IDs explicites
-- Nécessaire pour que le prochain AUTO-INCREMENT parte de la bonne valeur
SELECT setval('produits_PRO_id_seq',    (SELECT MAX(PRO_id) FROM produits));
SELECT setval('ressources_RE_id_seq',   (SELECT MAX(RE_id)  FROM ressources));
SELECT setval('utilisateurs_US_id_seq', (SELECT MAX(US_id)  FROM utilisateurs));
