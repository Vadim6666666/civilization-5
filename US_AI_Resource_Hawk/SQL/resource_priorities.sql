-- Усиление влияния нефти на военные предпочтения ИИ
UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 4 THEN 4 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_OIL' AND FlavorType = 'FLAVOR_OFFENSE';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_OIL', 'FLAVOR_OFFENSE', 4);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 3 THEN 3 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_OIL' AND FlavorType = 'FLAVOR_NAVAL';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_OIL', 'FLAVOR_NAVAL', 3);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 3 THEN 3 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_OIL' AND FlavorType = 'FLAVOR_AIR';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_OIL', 'FLAVOR_AIR', 3);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 5 THEN 5 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_OIL' AND FlavorType = 'FLAVOR_NUKE';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_OIL', 'FLAVOR_NUKE', 5);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 2 THEN 2 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_OIL' AND FlavorType = 'FLAVOR_PRODUCTION';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_OIL', 'FLAVOR_PRODUCTION', 2);

-- Подчёркивание исключительной ценности урана
UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 4 THEN 4 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_URANIUM' AND FlavorType = 'FLAVOR_OFFENSE';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_URANIUM', 'FLAVOR_OFFENSE', 4);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 3 THEN 3 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_URANIUM' AND FlavorType = 'FLAVOR_NAVAL';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_URANIUM', 'FLAVOR_NAVAL', 3);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 3 THEN 3 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_URANIUM' AND FlavorType = 'FLAVOR_AIR';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_URANIUM', 'FLAVOR_AIR', 3);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 5 THEN 5 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_URANIUM' AND FlavorType = 'FLAVOR_NUKE';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_URANIUM', 'FLAVOR_NUKE', 5);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 2 THEN 2 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_URANIUM' AND FlavorType = 'FLAVOR_PRODUCTION';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_URANIUM', 'FLAVOR_PRODUCTION', 2);

-- Дополнительная поддержка металлов для обычных войск
UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 2 THEN 2 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_ALUMINUM' AND FlavorType = 'FLAVOR_AIR';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_ALUMINUM', 'FLAVOR_AIR', 2);

UPDATE Resource_Flavors
SET Flavor = CASE WHEN Flavor < 2 THEN 2 ELSE Flavor END
WHERE ResourceType = 'RESOURCE_IRON' AND FlavorType = 'FLAVOR_OFFENSE';
INSERT OR IGNORE INTO Resource_Flavors (ResourceType, FlavorType, Flavor)
VALUES ('RESOURCE_IRON', 'FLAVOR_OFFENSE', 2);
