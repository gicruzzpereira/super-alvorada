ALTER TABLE pedidos
    ADD COLUMN data_entrega DATE NULL AFTER cep_entrega,
    ADD COLUMN horario_entrega VARCHAR(40) NULL AFTER data_entrega;
