-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: farma_market
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `farma_market`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `farma_market` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `farma_market`;

--
-- Temporary table structure for view `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!50001 DROP VIEW IF EXISTS `addresses`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `addresses` AS SELECT
 1 AS `id`,
  1 AS `user_id`,
  1 AS `label`,
  1 AS `recipient`,
  1 AS `street`,
  1 AS `number`,
  1 AS `complement`,
  1 AS `district`,
  1 AS `city`,
  1 AS `state`,
  1 AS `zip_code`,
  1 AS `is_default`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!50001 DROP VIEW IF EXISTS `brands`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `brands` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `manufacturer`,
  1 AS `active` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `slug` varchar(90) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Medicamentos','medicamentos'),(2,'Vitaminas','vitaminas'),(3,'Beleza','beleza'),(4,'Mamãe & Bebê','mamae-bebe'),(5,'Higiene','higiene');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!50001 DROP VIEW IF EXISTS `categories`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `categories` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `slug` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `enderecos`
--

DROP TABLE IF EXISTS `enderecos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enderecos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `identificacao` varchar(50) DEFAULT 'Casa',
  `destinatario` varchar(120) DEFAULT NULL,
  `logradouro` varchar(180) NOT NULL,
  `numero` varchar(20) NOT NULL,
  `complemento` varchar(100) DEFAULT NULL,
  `bairro` varchar(100) NOT NULL,
  `cidade` varchar(100) NOT NULL,
  `estado` char(2) NOT NULL,
  `cep` varchar(12) NOT NULL,
  `principal` tinyint(1) DEFAULT 0,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_endereco_usuario` (`usuario_id`),
  CONSTRAINT `fk_endereco_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enderecos`
--

LOCK TABLES `enderecos` WRITE;
/*!40000 ALTER TABLE `enderecos` DISABLE KEYS */;
INSERT INTO `enderecos` VALUES (1,1,'Casa','Marina Costa','Rua das Acácias','88','ap. 42','Vila Mariana','São Paulo','SP','04102-000',1,'2026-08-14 02:43:25'),(2,3,'Trabalho','João Almeida','Avenida Brigadeiro Faria Lima','3200','8º andar','Itaim Bibi','São Paulo','SP','04538-132',1,'2026-08-14 02:43:25');
/*!40000 ALTER TABLE `enderecos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `farmacias`
--

DROP TABLE IF EXISTS `farmacias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `farmacias` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `proprietario_id` bigint(20) unsigned NOT NULL,
  `nome` varchar(150) NOT NULL,
  `descricao` text DEFAULT NULL,
  `cnpj` varchar(25) DEFAULT NULL,
  `telefone` varchar(30) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `endereco` varchar(255) DEFAULT NULL,
  `cidade` varchar(100) DEFAULT NULL,
  `estado` char(2) DEFAULT NULL,
  `cep` varchar(12) DEFAULT NULL,
  `horario_funcionamento` varchar(180) DEFAULT NULL,
  `informacao_entrega` varchar(180) DEFAULT NULL,
  `foto_perfil_url` varchar(500) DEFAULT NULL,
  `imagem_capa_url` varchar(500) DEFAULT NULL,
  `avaliacao` decimal(2,1) DEFAULT 5.0,
  `verificada` tinyint(1) DEFAULT 0,
  `ativa` tinyint(1) DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cnpj` (`cnpj`),
  KEY `fk_farmacia_proprietario` (`proprietario_id`),
  CONSTRAINT `fk_farmacia_proprietario` FOREIGN KEY (`proprietario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `farmacias`
--

LOCK TABLES `farmacias` WRITE;
/*!40000 ALTER TABLE `farmacias` DISABLE KEYS */;
INSERT INTO `farmacias` VALUES (1,2,'Vico And Farma','Cuidando da sua saúde com atendimento próximo e entrega rápida.','12.345.678/0001-90','(11) 99999-2020','contato@farmacia.local','Rua das Flores, 120','São Paulo','SP','01001-000','Segunda a sábado, das 8h às 21h','Entrega expressa em até 2 horas',NULL,NULL,5.0,1,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(2,4,'Farmácia Saúde & Vida','Atendimento farmacêutico, medicamentos e cuidados para toda a família.','98.765.432/0001-10','(11) 97777-3344','contato@saudeevida.local','Avenida Paulista, 1500','São Paulo','SP','01310-200','Todos os dias, das 7h às 23h','Entrega no mesmo dia para a região central',NULL,NULL,4.8,1,1,'2026-08-14 02:43:25','2026-08-14 02:43:25');
/*!40000 ALTER TABLE `farmacias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!50001 DROP VIEW IF EXISTS `favorites`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `favorites` AS SELECT
 1 AS `user_id`,
  1 AS `product_id`,
  1 AS `created_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `favoritos`
--

DROP TABLE IF EXISTS `favoritos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favoritos` (
  `usuario_id` bigint(20) unsigned NOT NULL,
  `produto_id` bigint(20) unsigned NOT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`usuario_id`,`produto_id`),
  KEY `fk_favorito_produto` (`produto_id`),
  CONSTRAINT `fk_favorito_produto` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorito_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favoritos`
--

LOCK TABLES `favoritos` WRITE;
/*!40000 ALTER TABLE `favoritos` DISABLE KEYS */;
INSERT INTO `favoritos` VALUES (1,3,'2026-08-14 02:43:25'),(1,5,'2026-08-14 02:43:25'),(3,7,'2026-08-14 02:43:25'),(3,8,'2026-08-14 02:43:25');
/*!40000 ALTER TABLE `favoritos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itens_pedido`
--

DROP TABLE IF EXISTS `itens_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `itens_pedido` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pedido_id` bigint(20) unsigned NOT NULL,
  `produto_id` bigint(20) unsigned DEFAULT NULL,
  `nome_produto` varchar(180) NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `quantidade` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_item_pedido` (`pedido_id`),
  KEY `fk_item_produto` (`produto_id`),
  CONSTRAINT `fk_item_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_produto` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itens_pedido`
--

LOCK TABLES `itens_pedido` WRITE;
/*!40000 ALTER TABLE `itens_pedido` DISABLE KEYS */;
INSERT INTO `itens_pedido` VALUES (1,1,1,'Vitamina C 1000mg',34.90,1),(2,1,3,'Dipirona Sódica',12.90,1),(3,2,5,'Protetor Solar FPS 70',59.90,1),(4,3,7,'Ibuprofeno',22.90,1),(5,3,8,'Vitamina D3',39.90,1),(6,4,9,'Fraldas Premium M',74.50,1);
/*!40000 ALTER TABLE `itens_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marcas`
--

DROP TABLE IF EXISTS `marcas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marcas` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `fabricante` varchar(150) DEFAULT NULL,
  `ativa` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marcas`
--

LOCK TABLES `marcas` WRITE;
/*!40000 ALTER TABLE `marcas` DISABLE KEYS */;
INSERT INTO `marcas` VALUES (1,'Medley','Sanofi Medley',1),(2,'Neo Química','Hypera Pharma',1),(3,'EMS','Grupo NC',1),(4,'Cimed','Grupo Cimed',1),(5,'Eurofarma','Eurofarma',1),(6,'Bayer','Bayer Brasil',1),(7,'Genérico','Diversos',1);
/*!40000 ALTER TABLE `marcas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `medication_types`
--

DROP TABLE IF EXISTS `medication_types`;
/*!50001 DROP VIEW IF EXISTS `medication_types`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `medication_types` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `description`,
  1 AS `active` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!50001 DROP VIEW IF EXISTS `order_items`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `order_items` AS SELECT
 1 AS `id`,
  1 AS `order_id`,
  1 AS `product_id`,
  1 AS `product_name`,
  1 AS `unit_price`,
  1 AS `quantity` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!50001 DROP VIEW IF EXISTS `orders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `orders` AS SELECT
 1 AS `id`,
  1 AS `consumer_id`,
  1 AS `store_id`,
  1 AS `address_id`,
  1 AS `payment_method`,
  1 AS `total`,
  1 AS `status`,
  1 AS `created_at`,
  1 AS `updated_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedidos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `consumidor_id` bigint(20) unsigned NOT NULL,
  `farmacia_id` bigint(20) unsigned NOT NULL,
  `endereco_id` bigint(20) unsigned DEFAULT NULL,
  `forma_pagamento` enum('pix','cartao_credito','cartao_debito') NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `situacao` enum('novo','preparando','enviado','concluido','cancelado') DEFAULT 'novo',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_pedido_consumidor` (`consumidor_id`),
  KEY `fk_pedido_farmacia` (`farmacia_id`),
  KEY `fk_pedido_endereco` (`endereco_id`),
  CONSTRAINT `fk_pedido_consumidor` FOREIGN KEY (`consumidor_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `fk_pedido_endereco` FOREIGN KEY (`endereco_id`) REFERENCES `enderecos` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pedido_farmacia` FOREIGN KEY (`farmacia_id`) REFERENCES `farmacias` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,1,1,1,'pix',47.80,'novo','2026-08-14 02:23:25','2026-08-14 02:43:25'),(2,1,1,1,'cartao_credito',59.90,'preparando','2026-08-14 00:43:25','2026-08-14 02:43:25'),(3,3,2,2,'pix',62.80,'enviado','2026-08-13 02:43:25','2026-08-14 02:43:25'),(4,3,2,2,'cartao_debito',74.50,'concluido','2026-08-10 02:43:25','2026-08-14 02:43:25');
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `products`
--

DROP TABLE IF EXISTS `products`;
/*!50001 DROP VIEW IF EXISTS `products`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `products` AS SELECT
 1 AS `id`,
  1 AS `store_id`,
  1 AS `category_id`,
  1 AS `medication_type_id`,
  1 AS `brand_id`,
  1 AS `name`,
  1 AS `description`,
  1 AS `dosage`,
  1 AS `presentation`,
  1 AS `requires_prescription`,
  1 AS `sale_restriction`,
  1 AS `is_generic`,
  1 AS `price`,
  1 AS `old_price`,
  1 AS `stock`,
  1 AS `image_url`,
  1 AS `rating`,
  1 AS `review_count`,
  1 AS `active`,
  1 AS `created_at`,
  1 AS `updated_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `produtos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `farmacia_id` bigint(20) unsigned NOT NULL,
  `categoria_id` int(10) unsigned NOT NULL,
  `tipo_medicamento_id` int(10) unsigned DEFAULT NULL,
  `marca_id` int(10) unsigned DEFAULT NULL,
  `nome` varchar(180) NOT NULL,
  `descricao` text NOT NULL,
  `dosagem` varchar(80) DEFAULT NULL,
  `apresentacao` varchar(120) DEFAULT NULL,
  `exige_receita` tinyint(1) DEFAULT 0,
  `restricao_venda` enum('livre','vermelha_sem_retencao','vermelha_com_retencao','preta') DEFAULT 'livre',
  `generico` tinyint(1) DEFAULT 0,
  `preco` decimal(10,2) NOT NULL,
  `preco_anterior` decimal(10,2) DEFAULT NULL,
  `estoque` int(10) unsigned DEFAULT 0,
  `foto_url` varchar(500) DEFAULT NULL,
  `avaliacao` decimal(2,1) DEFAULT 5.0,
  `quantidade_avaliacoes` int(10) unsigned DEFAULT 0,
  `ativo` tinyint(1) DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_produto_farmacia` (`farmacia_id`),
  KEY `idx_produto_categoria` (`categoria_id`),
  KEY `idx_produto_tipo` (`tipo_medicamento_id`),
  KEY `idx_produto_marca` (`marca_id`),
  CONSTRAINT `fk_produto_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`),
  CONSTRAINT `fk_produto_farmacia` FOREIGN KEY (`farmacia_id`) REFERENCES `farmacias` (`id`),
  CONSTRAINT `fk_produto_marca` FOREIGN KEY (`marca_id`) REFERENCES `marcas` (`id`),
  CONSTRAINT `fk_produto_tipo` FOREIGN KEY (`tipo_medicamento_id`) REFERENCES `tipos_medicamento` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (1,1,2,5,7,'Vitamina C 1000mg','Suplemento vitamínico com 30 comprimidos.','1000 mg','30 comprimidos',0,'livre',0,34.90,42.90,28,NULL,4.9,126,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(2,1,2,5,7,'Ômega 3 1000mg','Suplemento alimentar com 60 cápsulas.','1000 mg','60 cápsulas',0,'livre',0,45.90,NULL,8,NULL,4.9,103,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(3,1,1,1,1,'Dipirona Sódica','Analgésico e antitérmico para alívio de dores e febre.','500 mg','Caixa com 20 comprimidos',0,'livre',0,12.90,15.90,45,NULL,4.8,87,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(4,1,1,3,2,'Loratadina','Antialérgico indicado para sintomas de rinite e alergias.','10 mg','Caixa com 12 comprimidos',0,'livre',0,18.50,NULL,16,NULL,4.7,62,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(5,1,3,6,3,'Protetor Solar FPS 70','Proteção facial contra raios UVA e UVB.','50 g','Frasco com 50 gramas',0,'livre',0,59.90,69.90,12,NULL,4.9,143,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(6,1,5,6,4,'Kit Higiene Bucal','Escova macia, creme dental e fio dental.','Kit','Embalagem com 3 itens',0,'livre',0,19.90,NULL,38,NULL,4.6,41,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(7,2,1,2,5,'Ibuprofeno','Anti-inflamatório para alívio temporário de dores.','400 mg','Caixa com 10 cápsulas',0,'livre',0,22.90,26.50,31,NULL,4.7,74,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(8,2,2,5,6,'Vitamina D3','Suplemento alimentar de vitamina D.','2000 UI','Frasco com 60 cápsulas',0,'livre',0,39.90,44.90,24,NULL,4.8,96,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(9,2,4,6,7,'Fraldas Premium M','Fraldas infantis com proteção prolongada.','Tamanho M','Pacote com 48 unidades',0,'livre',0,74.50,89.90,20,NULL,4.7,54,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(10,2,3,6,7,'Shampoo Nutritivo','Limpeza suave para cabelos ressecados.','350 ml','Frasco com 350 ml',0,'livre',0,26.90,NULL,27,NULL,4.6,71,1,'2026-08-14 02:43:25','2026-08-14 02:43:25');
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!50001 DROP VIEW IF EXISTS `stores`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `stores` AS SELECT
 1 AS `id`,
  1 AS `owner_id`,
  1 AS `name`,
  1 AS `description`,
  1 AS `cnpj`,
  1 AS `phone`,
  1 AS `email`,
  1 AS `address`,
  1 AS `city`,
  1 AS `state`,
  1 AS `zip_code`,
  1 AS `opening_hours`,
  1 AS `delivery_info`,
  1 AS `logo_url`,
  1 AS `banner_url`,
  1 AS `rating`,
  1 AS `verified`,
  1 AS `active`,
  1 AS `created_at`,
  1 AS `updated_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tipos_medicamento`
--

DROP TABLE IF EXISTS `tipos_medicamento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipos_medicamento` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(500) DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipos_medicamento`
--

LOCK TABLES `tipos_medicamento` WRITE;
/*!40000 ALTER TABLE `tipos_medicamento` DISABLE KEYS */;
INSERT INTO `tipos_medicamento` VALUES (1,'Analgésico e antitérmico','Alívio de dores e febre.',1),(2,'Anti-inflamatório','Controle de inflamações.',1),(3,'Antialérgico','Controle de alergias.',1),(4,'Antibiótico','Tratamento de infecções bacterianas.',1),(5,'Suplemento vitamínico','Vitaminas e minerais.',1),(6,'Dermatológico','Uso na pele.',1);
/*!40000 ALTER TABLE `tipos_medicamento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `users`
--

DROP TABLE IF EXISTS `users`;
/*!50001 DROP VIEW IF EXISTS `users`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `users` AS SELECT
 1 AS `id`,
  1 AS `name`,
  1 AS `email`,
  1 AS `password_hash`,
  1 AS `role`,
  1 AS `phone`,
  1 AS `cpf`,
  1 AS `active`,
  1 AS `created_at`,
  1 AS `updated_at` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `perfil` enum('consumidor','vendedor','administrador') NOT NULL,
  `telefone` varchar(30) DEFAULT NULL,
  `cpf` varchar(20) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `cpf` (`cpf`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Marina Costa','marina@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','consumidor','(11) 98765-4321',NULL,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(2,'Vendedor Farma','vendedor@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','vendedor','(11) 99999-2020',NULL,1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(3,'João Almeida','joao@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','consumidor','(11) 98888-1122','123.456.789-00',1,'2026-08-14 02:43:25','2026-08-14 02:43:25'),(4,'Ana Farmacêutica','ana@farma.local','$2b$12$DdQoydPJebvzzTRmeRbgxOBdisB5geT8y9NWDQvm4rqs9f4OXQswi','vendedor','(11) 97777-3344',NULL,1,'2026-08-14 02:43:25','2026-08-14 02:43:25');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'farma_market'
--

--
-- Dumping routines for database 'farma_market'
--

--
-- Current Database: `farma_market`
--

USE `farma_market`;

--
-- Final view structure for view `addresses`
--

/*!50001 DROP VIEW IF EXISTS `addresses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `addresses` AS select `enderecos`.`id` AS `id`,`enderecos`.`usuario_id` AS `user_id`,`enderecos`.`identificacao` AS `label`,`enderecos`.`destinatario` AS `recipient`,`enderecos`.`logradouro` AS `street`,`enderecos`.`numero` AS `number`,`enderecos`.`complemento` AS `complement`,`enderecos`.`bairro` AS `district`,`enderecos`.`cidade` AS `city`,`enderecos`.`estado` AS `state`,`enderecos`.`cep` AS `zip_code`,`enderecos`.`principal` AS `is_default`,`enderecos`.`criado_em` AS `created_at` from `enderecos` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `brands`
--

/*!50001 DROP VIEW IF EXISTS `brands`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `brands` AS select `marcas`.`id` AS `id`,`marcas`.`nome` AS `name`,`marcas`.`fabricante` AS `manufacturer`,`marcas`.`ativa` AS `active` from `marcas` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `categories`
--

/*!50001 DROP VIEW IF EXISTS `categories`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `categories` AS select `categorias`.`id` AS `id`,`categorias`.`nome` AS `name`,`categorias`.`slug` AS `slug` from `categorias` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `favorites`
--

/*!50001 DROP VIEW IF EXISTS `favorites`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `favorites` AS select `favoritos`.`usuario_id` AS `user_id`,`favoritos`.`produto_id` AS `product_id`,`favoritos`.`criado_em` AS `created_at` from `favoritos` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `medication_types`
--

/*!50001 DROP VIEW IF EXISTS `medication_types`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `medication_types` AS select `tipos_medicamento`.`id` AS `id`,`tipos_medicamento`.`nome` AS `name`,`tipos_medicamento`.`descricao` AS `description`,`tipos_medicamento`.`ativo` AS `active` from `tipos_medicamento` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `order_items`
--

/*!50001 DROP VIEW IF EXISTS `order_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `order_items` AS select `itens_pedido`.`id` AS `id`,`itens_pedido`.`pedido_id` AS `order_id`,`itens_pedido`.`produto_id` AS `product_id`,`itens_pedido`.`nome_produto` AS `product_name`,`itens_pedido`.`preco_unitario` AS `unit_price`,`itens_pedido`.`quantidade` AS `quantity` from `itens_pedido` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `orders`
--

/*!50001 DROP VIEW IF EXISTS `orders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `orders` AS select `pedidos`.`id` AS `id`,`pedidos`.`consumidor_id` AS `consumer_id`,`pedidos`.`farmacia_id` AS `store_id`,`pedidos`.`endereco_id` AS `address_id`,case `pedidos`.`forma_pagamento` when 'cartao_credito' then 'credit_card' when 'cartao_debito' then 'debit_card' else 'pix' end AS `payment_method`,`pedidos`.`total` AS `total`,case `pedidos`.`situacao` when 'novo' then 'new' when 'preparando' then 'preparing' when 'enviado' then 'shipped' when 'concluido' then 'completed' else 'cancelled' end AS `status`,`pedidos`.`criado_em` AS `created_at`,`pedidos`.`atualizado_em` AS `updated_at` from `pedidos` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `products`
--

/*!50001 DROP VIEW IF EXISTS `products`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `products` AS select `produtos`.`id` AS `id`,`produtos`.`farmacia_id` AS `store_id`,`produtos`.`categoria_id` AS `category_id`,`produtos`.`tipo_medicamento_id` AS `medication_type_id`,`produtos`.`marca_id` AS `brand_id`,`produtos`.`nome` AS `name`,`produtos`.`descricao` AS `description`,`produtos`.`dosagem` AS `dosage`,`produtos`.`apresentacao` AS `presentation`,`produtos`.`exige_receita` AS `requires_prescription`,case `produtos`.`restricao_venda` when 'livre' then 'otc' when 'vermelha_sem_retencao' then 'red_no_retention' when 'vermelha_com_retencao' then 'red_retention' else 'black' end AS `sale_restriction`,`produtos`.`generico` AS `is_generic`,`produtos`.`preco` AS `price`,`produtos`.`preco_anterior` AS `old_price`,`produtos`.`estoque` AS `stock`,`produtos`.`foto_url` AS `image_url`,`produtos`.`avaliacao` AS `rating`,`produtos`.`quantidade_avaliacoes` AS `review_count`,`produtos`.`ativo` AS `active`,`produtos`.`criado_em` AS `created_at`,`produtos`.`atualizado_em` AS `updated_at` from `produtos` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `stores`
--

/*!50001 DROP VIEW IF EXISTS `stores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `stores` AS select `farmacias`.`id` AS `id`,`farmacias`.`proprietario_id` AS `owner_id`,`farmacias`.`nome` AS `name`,`farmacias`.`descricao` AS `description`,`farmacias`.`cnpj` AS `cnpj`,`farmacias`.`telefone` AS `phone`,`farmacias`.`email` AS `email`,`farmacias`.`endereco` AS `address`,`farmacias`.`cidade` AS `city`,`farmacias`.`estado` AS `state`,`farmacias`.`cep` AS `zip_code`,`farmacias`.`horario_funcionamento` AS `opening_hours`,`farmacias`.`informacao_entrega` AS `delivery_info`,`farmacias`.`foto_perfil_url` AS `logo_url`,`farmacias`.`imagem_capa_url` AS `banner_url`,`farmacias`.`avaliacao` AS `rating`,`farmacias`.`verificada` AS `verified`,`farmacias`.`ativa` AS `active`,`farmacias`.`criado_em` AS `created_at`,`farmacias`.`atualizado_em` AS `updated_at` from `farmacias` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `users`
--

/*!50001 DROP VIEW IF EXISTS `users`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `users` AS select `usuarios`.`id` AS `id`,`usuarios`.`nome` AS `name`,`usuarios`.`email` AS `email`,`usuarios`.`senha_hash` AS `password_hash`,case `usuarios`.`perfil` when 'consumidor' then 'consumer' when 'vendedor' then 'seller' else 'admin' end AS `role`,`usuarios`.`telefone` AS `phone`,`usuarios`.`cpf` AS `cpf`,`usuarios`.`ativo` AS `active`,`usuarios`.`criado_em` AS `created_at`,`usuarios`.`atualizado_em` AS `updated_at` from `usuarios` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-13 23:55:00
