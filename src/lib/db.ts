import { Pool, type QueryResult, type QueryResultRow } from "pg";

const pool = new Pool({
    connectionString: import.meta.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: false,
    },
});

export async function query<T extends QueryResultRow>(
    text: string,
    params: unknown[] = []
): Promise<QueryResult<T>> {
    try {
        return await pool.query<T>(text, params);
    } catch (error) {
        console.error("Error en la consulta a la base de datos:", error);
        throw error;
    }
}

export default pool;
