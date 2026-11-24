ALTER TABLE pedidos
    MODIFY id_endereco INT NULL,
    ADD COLUMN modalidade_entrega ENUM('expressa','agendada','retirada') NOT NULL DEFAULT 'agendada' AFTER metodo_pagamento,
    ADD COLUMN cep_entrega VARCHAR(9) NULL AFTER modalidade_entrega;
