CREATE TABLE IF NOT EXISTS cupons (
    id_cupom INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(40) NOT NULL UNIQUE,
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    tipo ENUM('percentual','fixo') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    pedido_minimo DECIMAL(10,2) NOT NULL DEFAULT 0,
    validade DATE NULL,
    limite_usos INT NULL,
    usos INT NOT NULL DEFAULT 0,
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

ALTER TABLE pedidos
    ADD COLUMN id_cupom INT NULL,
    ADD COLUMN valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
    ADD CONSTRAINT fk_pedidos_cupom FOREIGN KEY (id_cupom) REFERENCES cupons(id_cupom);

CREATE TABLE IF NOT EXISTS cupons_clientes (
    id_cupom_cliente INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_cupom INT NOT NULL,
    id_pedido INT NULL,
    resgatado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usado_em TIMESTAMP NULL,
    UNIQUE KEY uk_cupom_cliente(id_usuario,id_cupom),
    FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY(id_cupom) REFERENCES cupons(id_cupom) ON DELETE CASCADE,
    FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido) ON DELETE SET NULL
) ENGINE=InnoDB;
