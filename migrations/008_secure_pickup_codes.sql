ALTER TABLE pedidos
    MODIFY pin_entrega VARCHAR(6) NOT NULL,
    ADD UNIQUE KEY uq_pedidos_pin_entrega (pin_entrega);
