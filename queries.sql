-- Funkciya, opredelyayushchaya nalichie opredelennoj stat'i na opredelennoj yazyke.
-- Ispol'zuetsya v odnom iz predstavlenij.

DROP FUNCTION IF EXISTS language_article;

DELIMITER //

CREATE FUNCTION language_article (art_id INT, lang_id INT)
RETURNS VARCHAR(3) READS SQL DATA
BEGIN
	SET @r = (SELECT editing_id FROM current_bodies WHERE
	           language_id = lang_id 
	           AND article_id  = art_id LIMIT 1);
	          
    IF(@r IS NOT NULL) THEN
      RETURN 'YES';
    ELSE
      RETURN 'NO';
    END IF;
END//

DELIMITER ;

-- Procedura dlya polucheniya kolichestva statej v opredelennoj kategorii

DROP PROCEDURE IF EXISTS articles_count;

DELIMITER //

CREATE PROCEDURE articles_count (IN category_name VARCHAR(45))

BEGIN
	SET @cat_id = (SELECT id FROM categories WHERE name = category_name);

    IF(@cat_id IS NOT NULL) THEN
      SELECT COUNT(article_id) FROM categories_articles WHERE category_id = @cat_id;
    ELSE
      SELECT 'No articles in this category';
    END IF;
END//

DELIMITER ;

-- Poluchenie teksta stat'i po id i yazyku

SELECT current_bodies.body FROM articles 
  JOIN current_bodies
    ON current_bodies.article_id = articles.id  
  JOIN languages 
    ON current_bodies.language_id = languages.id
WHERE articles.id = 309 
  AND languages.id = 1;
 
 
-- Vybor spiska statej po kategorii

SELECT articles.id FROM articles 
  JOIN categories_articles 
    ON articles.id = categories_articles.article_id 
  JOIN categories 
    ON categories.id = categories_articles.category_id 
  WHERE categories.id = 1;


-- Podborka media po kategorii
 
 SELECT media.id, media.filename FROM media
   JOIN articles 
     ON media.article_id = articles.id 
   JOIN categories_articles 
     ON categories_articles.article_id = articles.id 
   JOIN categories 
     ON categories.id = categories_articles.category_id 
   WHERE categories.name = 'enim';
   
-- Statistika po provedennym v stat'yah pravkam

CREATE VIEW edit_makers AS
  SELECT editings.id AS 'id', 
         editings.is_confirmed AS 'confirmed',
         editings.created_at AS 'created at',
         editors.id AS 'editor', 
         editors.is_registred AS 'editor is registred',
         users.name AS 'name', 
         articles.id AS 'article' 
  FROM editings
    JOIN editors 
      ON editors.id = editings.editor_id 
    LEFT JOIN users
      ON users.editor_id = editors.id 
    JOIN current_bodies 
      ON current_bodies.editing_id  = editings.id 
    JOIN articles 
      ON articles.id = current_bodies.article_id;
  
     
-- Statistika nalichiya teksta statej na raznyh yazykah

CREATE VIEW articles_languages AS
  SELECT articles.id,
         language_article(articles.id, 1) AS 'EN',
         language_article(articles.id, 2) AS 'CN',
         language_article(articles.id, 3) AS 'DE',
         language_article(articles.id, 4) AS 'ES',
         language_article(articles.id, 5) AS 'FR',
         language_article(articles.id, 6) AS 'IT',
         language_article(articles.id, 7) AS 'RU'
  FROM articles;