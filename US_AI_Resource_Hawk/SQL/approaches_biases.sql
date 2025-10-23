-- Настройка агрессивных подходов к крупным державам
INSERT OR REPLACE INTO Leader_MajorCivApproachBiases (LeaderType, MajorCivApproachType, Bias)
VALUES
('LEADER_WASHINGTON', 'MAJOR_CIV_APPROACH_WAR', 9),
('LEADER_WASHINGTON', 'MAJOR_CIV_APPROACH_CONQUEST', 9),
('LEADER_WASHINGTON', 'MAJOR_CIV_APPROACH_HOSTILE', 8),
('LEADER_WASHINGTON', 'MAJOR_CIV_APPROACH_DECEPTIVE', 7);

-- Хищное отношение к городам-государствам
INSERT OR REPLACE INTO Leader_MinorCivApproachBiases (LeaderType, MinorCivApproachType, Bias)
VALUES
('LEADER_WASHINGTON', 'MINOR_CIV_APPROACH_BULLY', 9),
('LEADER_WASHINGTON', 'MINOR_CIV_APPROACH_CONQUEST', 9);
