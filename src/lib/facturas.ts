import pool from "./db";

interface DetalleFactura {
    productoId: number;
    cantidad: number;
    precio: number;
    descuento?: number;
}

interface NuevaFactura {
    clienteId: string;
    stripePaymentIntentId: string;
    iva: number;
    metodoPago: string;
    referenciaPago: string;
    banco?: string | null;
    productos: DetalleFactura[];
}

export async function crearFactura({
    clienteId,
    stripePaymentIntentId,
    iva,
    metodoPago,
    referenciaPago,
    banco = null,
    productos,
}: NuevaFactura) {
    if (productos.length === 0) {
        throw new Error("La factura debe tener productos");
    }

    const client = await pool.connect();

    try {
        await client.query("BEGIN");

        const { rows } = await client.query(
            `INSERT INTO facturas (
                fk_cliente,
                stripe_payment_intent_id,
                iva,
                metodo_pago,
                referencia_pago,
                banco
            )
            VALUES ($1, $2, $3, $4, $5, $6)
            ON CONFLICT (stripe_payment_intent_id)
            DO NOTHING
            RETURNING *`,
            [
                clienteId,
                stripePaymentIntentId,
                iva,
                metodoPago,
                referenciaPago,
                banco,
            ]
        );

        let factura = rows[0];

        if (factura) {
            for (const producto of productos) {
                await client.query(
                    `INSERT INTO detalle_factura (
                        fk_factura,
                        fk_producto,
                        cantidad,
                        precio,
                        descuento
                    )
                    VALUES ($1, $2, $3, $4, $5)
                    ON CONFLICT (fk_factura, fk_producto)
                    DO NOTHING`,
                    [
                        factura.pk_factura,
                        producto.productoId,
                        producto.cantidad,
                        producto.precio,
                        producto.descuento ?? 0,
                    ]
                );
            }

            await client.query(
                "SELECT asignar_numero_factura($1)",
                [factura.pk_factura]
            );

            const resultado = await client.query(
                "SELECT * FROM facturas WHERE pk_factura = $1",
                [factura.pk_factura]
            );

            factura = resultado.rows[0];
        } else {
            const resultado = await client.query(
                `SELECT * FROM facturas
                 WHERE stripe_payment_intent_id = $1`,
                [stripePaymentIntentId]
            );

            factura = resultado.rows[0];
        }

        await client.query("COMMIT");
        return factura;

    } catch (error) {
        await client.query("ROLLBACK");
        console.error("Error al registrar la factura:", error);
        throw error;
    } finally {
        client.release();
    }
}
