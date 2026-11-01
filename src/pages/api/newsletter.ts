import type { APIRoute } from "astro";
import pool from "../../lib/db";

export const POST: APIRoute = async ({ request }) => {
    try {
        const { email, consentimiento } = await request.json();

        if (typeof email !== "string" ||
            email.length > 255 ||
            !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
            return new Response(
                JSON.stringify({ error: "Introduce un correo válido." }),
                { status: 400 }
            );
        }

        if (consentimiento !== true) {
            return new Response(
                JSON.stringify({ error: "Debes aceptar recibir comunicaciones." }),
                { status: 400 }
            );
        }

        const resultado = await pool.query(
            `INSERT INTO suscriptores_newsletter (email)
             VALUES ($1)
             ON CONFLICT (email) DO NOTHING
             RETURNING id_suscriptor`,
            [email.trim().toLowerCase()]
        );

        return new Response(
            JSON.stringify({
                mensaje: resultado.rowCount
                    ? "¡Te has suscrito correctamente!"
                    : "Este correo ya está registrado."
            }),
            { status: 200 }
        );

    } catch (error) {
        console.error("Error en newsletter:", error);

        return new Response(
            JSON.stringify({ error: "No se pudo completar la suscripción." }),
            { status: 500 }
        );
    }
};
