INSERT INTO configuracoes(chave, valor) VALUES
    ('loja_latitude', '-23.55052'),
    ('loja_longitude', '-46.63331'),
    ('agendamento_dias', '1,2,3,4,5,6'),
    ('agendamento_horarios', '09:00-12:00
14:00-18:00')
ON DUPLICATE KEY UPDATE valor = VALUES(valor);
