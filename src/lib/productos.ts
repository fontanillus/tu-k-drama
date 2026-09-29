import { query } from "./db";

export interface Producto {
    pk_producto: number;
    nombre_producto: string;
    precio: number;
    fk_categoria: number;
    stock: number;
    url_imagen: string | null;
    descripcion_producto: string | null;
    descuento: number;
    punto_reposicion: number;
}

export async function getProductosPorCategoria(
    categoriaId: number
): Promise<Producto[]> {
    const result = await query<Producto>(
        "SELECT * FROM productos WHERE fk_categoria = $1",
        [categoriaId]
    );

    return result.rows;
}

export async function getProductoPorId(
    productoId: number
): Promise<Producto | null> {
    const result = await query<Producto>(
        "SELECT * FROM productos WHERE pk_producto = $1",
        [productoId]
    );

    return result.rows[0] ?? null;
}
