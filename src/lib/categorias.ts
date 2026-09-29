import { query } from "./db";

export interface Categoria {
    pk_categoria: number;
    nom_categoria: string;
    descripcion_categoria: string | null;
}
export async function getCategorias(): Promise<Categoria[]> {
    const result = await query<Categoria>(
        "SELECT * FROM categorias"
    );

    return result.rows;
}
