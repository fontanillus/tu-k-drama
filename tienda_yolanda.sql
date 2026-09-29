-- =====================================================
-- TABLA CLIENTES
-- =====================================================
-- pk_cliente utiliza UUID porque referencia al identificador de auth.users de Supabase.
-- ON DELETE CASCADE: si se elimina el usuario de auth.users, también se elimina su registro asociado en clientes.
-- ON UPDATE CASCADE: si cambia el identificador del usuario referenciado, el cambio se propaga a clientes.
-- CHECK en tipo: limita los valores permitidos a empresa o autónomo.
-- CHECK en rol: limita los valores permitidos a cliente o administrador.
-- =====================================================

CREATE TABLE clientes (
    pk_cliente UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    email VARCHAR(255) NOT NULL,
    dni_cif VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL
    CHECK (tipo IN ('empresa', 'autónomo')),
    razon_social VARCHAR(100) NOT NULL,
    nombres_cliente VARCHAR(100) NOT NULL,
    apellido1_cliente VARCHAR(50) NOT NULL,
    apellido2_cliente VARCHAR(50),
    telefono_movil VARCHAR(15) NOT NULL,
    rol VARCHAR(20) NOT NULL
    CHECK (rol IN ('cliente', 'administrador')),
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA CATEGORIAS
-- =====================================================

CREATE TABLE categorias (
    pk_categoria INT PRIMARY KEY,
    nom_categoria VARCHAR(100) NOT NULL,
    descripcion_categoria TEXT
);

-- =====================================================
-- INSERTAR CATEGORIAS
-- =====================================================

INSERT INTO categorias (
    pk_categoria,
    nom_categoria,
    descripcion_categoria
)
VALUES
    (1, 'K-Drama & Coleccionables',
        'OST, photobooks y objetos coleccionables relacionados con K-Dramas'),

    (2, 'Moda & Accesorios',
        'Moda, joyería y accesorios vistos o inspirados en K-Dramas'),

    (3, 'K-Beauty',
        'Productos de belleza y cosmética vistos en K-Dramas'),

    (4, 'Papelería & Lifestyle',
        'Papelería y productos lifestyle relacionados con K-Dramas'),

    (5, 'Hogar & Decoración',
        'Artículos para el hogar y decoración vistos o inspirados en K-Dramas');

-- =====================================================
-- TABLA PRODUCTOS
-- =====================================================
-- Cada producto pertenece a una única categoría.
-- ON DELETE RESTRICT: impide eliminar una categoría mientras tenga productos asociados.
-- ON UPDATE CASCADE: si cambia la clave primaria de una categoría, el cambio se propaga a sus productos.
-- El IVA se almacena en FACTURAS porque todos los productos de Tu K-Drama aplican el mismo tipo de IVA (21%).
-- NOT NULL en fk_categoria: garantiza que todo producto pertenezca a una categoría.
-- CHECK en precio: impide almacenar precios negativos.
-- CHECK en stock: permite stock 0 para productos agotados, pero impide valores negativos.
-- CHECK en descuento: limita el porcentaje de descuento entre 0% y 100%.
-- =====================================================

CREATE TABLE productos (
    pk_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
    CHECK (precio >= 0),

    fk_categoria INT NOT NULL REFERENCES categorias(pk_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    stock INT NOT NULL
    CHECK (stock >= 0),
    url_imagen TEXT,
    descripcion_producto TEXT NOT NULL,
    descuento DECIMAL(5,2) DEFAULT 0
    CHECK (descuento >= 0 AND descuento <= 100),
    punto_reposicion INT,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_baja TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- =====================================================
-- TABLA FACTURAS
-- =====================================================
-- Cada factura pertenece a un cliente.
-- ON DELETE RESTRICT: impide eliminar un cliente que tenga facturas asociadas, conservando así el historial de facturación.
-- ON UPDATE CASCADE: si cambia la clave primaria del cliente, el cambio se propaga a sus facturas.
-- NOT NULL en fk_cliente: garantiza que toda factura pertenezca a un cliente.
-- CHECK en iva: impide almacenar porcentajes de IVA negativos.
-- UNIQUE en stripe_payment_intent_id: evita registrar dos facturas con la misma operación de pago.
-- =====================================================

CREATE TABLE facturas (
    pk_factura INT PRIMARY KEY,

    fk_cliente UUID NOT NULL REFERENCES clientes(pk_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    fecha_compra TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    stripe_payment_intent_id TEXT NOT NULL UNIQUE,
    iva DECIMAL(5,2) NOT NULL
    CHECK (iva >= 0),
    metodo_pago VARCHAR(20) NOT NULL,
    referencia_pago VARCHAR(100) NOT NULL,
    banco VARCHAR(100)
);

-- =====================================================
-- TABLA DETALLE_FACTURA
-- =====================================================
-- Cada línea de detalle pertenece a una factura y corresponde a un producto.
-- ON DELETE RESTRICT:
-- impide eliminar una factura o un producto mientras existan líneas de detalle asociadas, conservando
-- la integridad del historial de compra.
-- ON UPDATE CASCADE: si cambia la clave primaria de una factura o producto, el cambio se propaga a detalle_factura.
-- precio_total es una columna calculada automáticamente a partir del precio_unitario y la cantidad.
-- CHECK en cantidad: obliga a que la cantidad comprada sea mayor que 0.
-- CHECK en precio_unitario: impide almacenar precios unitarios negativos.
-- CHECK en descuento: limita el porcentaje de descuento entre 0% y 100%.
-- PRIMARY KEY compuesta (fk_factura, fk_producto): identifica de forma única cada línea de producto dentro de una factura.
-- =====================================================

CREATE TABLE detalle_factura (
    fk_factura INT REFERENCES facturas(pk_factura)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    fk_producto INT REFERENCES productos(pk_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    cantidad INT NOT NULL
    CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL
    CHECK (precio_unitario >= 0),

    precio_total NUMERIC(10,2)
    GENERATED ALWAYS AS (precio_unitario * cantidad) STORED,

   descuento DECIMAL(5,2) DEFAULT 0
   CHECK (descuento >= 0 AND descuento <= 100),

    PRIMARY KEY (fk_factura, fk_producto)
);

-- =====================================================
-- INSERTAR PRODUCTOS
-- 30 productos: 6 productos por cada categoría
-- =====================================================

INSERT INTO productos (
    pk_producto,
    nombre_producto,
    precio,
    fk_categoria,
    stock,
    url_imagen,
    descripcion_producto,
    descuento,
    punto_reposicion
)
VALUES

-- =====================================================
-- CATEGORÍA 1: K-Drama & Coleccionables
-- =====================================================

(1, 'Collector Box - The King: Eternal Monarch', 59.90, 1, 10,
'https://tse1.mm.bing.net/th/id/OIP.G0wz3etaUwcWnIjR7j9YhQHaFU?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
'Collector Box con réplica del billete, OST y photobook de The King: Eternal Monarch.', 0, 3),

(2, 'OST Deluxe - Goblin', 49.90, 1, 8,
'https://cdn.shopify.com/s/files/1/0566/6766/8616/files/Goblin_OST_Album_Pack_2_1-min.jpg?v=1653270144',
'Edición Deluxe de la OST de Goblin con photobook y postales.', 0, 3),

(3, 'Photobook - Business Proposal', 34.90, 1, 12,
'https://cf.shopee.co.id/file/id-11134207-7r98t-lxe5dwi46mfydf',
'Photobook de Business Proposal con álbum de fotografías y photocards.', 0, 4),

(4, 'OST Special Edition - Vincenzo', 44.90, 1, 7,
'https://static.wikia.nocookie.net/kpop/images/a/a3/Vincenzo_OST_Full_OST_cover.png/revision/latest?cb=20210503113609',
'OST Special Edition de Vincenzo con photobook y postales.', 0, 3),

(5, 'OST y álbum fotográfico - Mr. Queen', 42.90, 1, 9,
'https://tse1.mm.bing.net/th/id/OIP.Dx-0ZTj0IFbD_8qS39O3eQHaFj?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
'OST de Mr. Queen con álbum fotográfico ambientado en Joseon y postales.', 0, 3),

(27, 'OST - Hwarang', 39.90, 1, 10,
'https://makeshop-multi-images.akamaized.net/wowkpop/itemimages/0000000027612_25gbDkh.jpg',
'Banda sonora original de Hwarang: The Poet Warrior Youth, presentada en edición física para coleccionistas y fans del K-Drama.', 0, 3),

-- =====================================================
-- CATEGORÍA 2: Moda & Accesorios
-- =====================================================

(6, 'Collar Kissing Star - Boys Over Flowers', 29.90, 2, 15,
'https://i.pinimg.com/736x/c8/39/9d/c8399dde6a9610f995d3b18de295b201.jpg',
'Collar Kissing Star inspirado en Boys Over Flowers.', 0, 5),

(7, 'Collar Flor de Ciruelo - The King: Eternal Monarch', 34.90, 2, 12,
'https://sonotsizezero.com/cdn/shop/files/the-king-eternal-monarch-kim-go-eun-inspired-necklace-001-one-size-only-rose-gold-50-100-accessories-allcollections-collectionthekingeternalmonarch-gift-833_480x480.png?v=1688797940',
'Collar Flor de Ciruelo inspirado en The King: Eternal Monarch.', 0, 4),

(8, 'Mechero dorado - Vincenzo', 24.90, 2, 10,
'https://i.pinimg.com/736x/ae/14/75/ae1475d7467ffd90c4bc67d5711981af.jpg',
'Mechero dorado inspirado en el utilizado en Vincenzo.', 0, 3),

(9, 'Gafas de sol - The King: Eternal Monarch', 79.90, 2, 6,
'https://kuyou.id/content/images/20200427063858-6-muncul-dengan-karakter-yang-keren-lee-gon-mengenakan-kacamata-dari-gentle-monster-dengan-harga-rp4-juta-guys.jpg',
'Gafas de sol inspiradas en el estilo de The King: Eternal Monarch.', 0, 2),

(10, 'Gorra Danbam - Itaewon Class', 27.90, 2, 14,
'https://i.etsystatic.com/47095969/r/il/6008f8/5634259673/il_1080xN.5634259673_9l3i.jpg',
'Gorra Danbam inspirada en Itaewon Class.', 0, 4),

(11, 'Hanbok tradicional femenino - K-Drama', 89.90, 2, 8,
'https://yandanhanfu.com/cdn/shop/files/Korean_Hanbok_Dress_Hand_Embroidered_Floral_Skirt_White_Jeogori_for_Weddings_Festivals_Ceremonies.jpg?v=1774926614&width=1179',
'Hanbok femenino tradicional inspirado en los vestuarios coreanos vistos en K-Dramas históricos y contemporáneos.', 0, 3),

-- =====================================================
-- CATEGORÍA 3: K-Beauty
-- =====================================================

(12, 'KAHI Wrinkle Bounce Multi Balm', 29.90, 3, 20,
'https://th.bing.com/th/id/R.a91d48413db3b66d06db55db40c30241?rik=gMJZXpnu0b%2bosw&riu=http%3a%2f%2fkoyabeauty.com%2fcdn%2fshop%2ffiles%2f9_3b0c3c8b-45e0-44cc-8057-41f46c559dd2.png%3fv%3d1756721473&ehk=do7miXY76vHOeOz7lsIQKiBUZqUDSlXC%2f0nmGrgWjqM%3d&risl=&pid=ImgRaw&r=0',
'Bálsamo facial KAHI Wrinkle Bounce Multi Balm visto en The King: Eternal Monarch.', 0, 5),

(13, 'Colorgram Lip Tint', 16.90, 3, 18,
'https://img.joomcdn.net/fc065931831ff177fc4d148e9f826b818ab8c261_original.jpeg',
'Tinte labial Colorgram inspirado en los productos vistos en True Beauty.', 0, 5),

(14, 'Laneige Neo Cushion', 39.90, 3, 15,
'https://tse1.explicit.bing.net/th/id/OIP.0PW1RHRCVFnyNen48kPR1AHaJ4?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
'Cushion de Laneige relacionado con Descendants of the Sun.', 0, 4),

(15, 'EUNYUL Moisture Glow Balm', 19.90, 3, 17,
'https://incidecoder-content.storage.googleapis.com/b3985125-8fae-49ee-b4b3-99a5c6fb59fe/products/eunyul-moisture-glow-multi-balm/eunyul-moisture-glow-multi-balm_front_photo_original.jpeg',
'Bálsamo hidratante EUNYUL Moisture Glow Balm visto en distintos K-Dramas.', 0, 5),

(16, 'Mediheal N.M.F Aquaring Ampoule Mask', 4.90, 3, 30,
'https://cdn.shopify.com/s/files/1/0051/4578/8450/products/Mediheal_N.M.F_Aquaring_Ampoule_Mask_3.jpg?v=1580434862',
'Mascarilla facial Mediheal N.M.F Aquaring Ampoule Mask relacionada con Crash Landing on You.', 0, 10),

(28, 'Set de Mascarillas Coreanas Esfolio K-Beauty - 11 piezas', 24.90, 3, 15,
'https://http2.mlstatic.com/D_NQ_NP_895633-MLM49948687875_052022-O.webp',
'Set de 11 mascarillas faciales coreanas Esfolio, representativas de las rutinas de K-Beauty que aparecen habitualmente en series coreanas.', 0, 5),

-- =====================================================
-- CATEGORÍA 4: Papelería & Lifestyle
-- =====================================================

(17, 'Lápiz Staedtler Mars Lumograph', 3.90, 4, 30,
'https://http2.mlstatic.com/D_NQ_NP_821349-MLA46180812628_052021-O.webp',
'Lápiz Staedtler Mars Lumograph azul y negro inspirado en The Glory.', 0, 10),

(18, 'Planner - Extraordinary Attorney Woo', 19.90, 4, 15,
'https://i.etsystatic.com/43214462/r/il/9f3069/4977103043/il_fullxfull.4977103043_1wt4.jpg',
'Planner inspirado en Extraordinary Attorney Woo.', 0, 5),

(19, 'Kit Dalgona - Squid Game', 14.90, 4, 20,
'https://down-sg.img.susercontent.com/file/90c1a04f496e7c1dcc3a1de8273f14c5',
'Kit para preparar el tradicional juego Dalgona inspirado en Squid Game.', 0, 5),

(20, 'Paraguas amarillo - Lovely Runner', 24.90, 4, 12,
'https://shopluxcardenas.com/wp-content/uploads/2024/06/MDlovely20.jpg',
'Paraguas amarillo inspirado en Lovely Runner.', 0, 4),

(21, 'Set de stickers Lee Gon - The King: Eternal Monarch', 9.90, 4, 25,
'https://i.pinimg.com/736x/8a/a7/bd/8aa7bde2427350b256dbca095ee18fed.jpg',
'Set de stickers inspirado en Lee Gon y The King: Eternal Monarch.', 0, 8),

(29, 'Libreta tapa dura BTS - BT21', 14.90, 4, 20,
'https://http2.mlstatic.com/D_NQ_NP_741273-MLC81456848900_122024-O.webp',
'Libreta de tapa dura inspirada en BTS y los personajes BT21, ideal para notas, planificación y uso diario.', 0, 5),

-- =====================================================
-- CATEGORÍA 5: Hogar & Decoración
-- =====================================================

(22, 'Muñeco Minomi', 34.90, 5, 10,
'https://pbs.twimg.com/media/EWhWpgrU8AEBF08.jpg:large',
'Muñeco Minomi relacionado con Personal Taste y el universo de Lee Min-ho.', 0, 3),

(23, 'Taza de flores - Crash Landing on You', 18.90, 5, 15,
'https://images.openai.com/static-rsc-4/edTHDxQqr4y7KD771i_cSe_bxv0qPb7NXCa4NlrlsuoZSTIn-K3uziuWROYwHqxxZhAjhOimVVxjARvyKBqmBi2vYSJgsCAuKvrcnRp1uyWOcYZwhgTSE95UU3UbZsZA98RxPbvXKbBwtAocLIFnlx08MLxsVOyHEkpTQsSJ1tkR38MzBQKBY4ZSELMyDtMj?purpose=fullsize',
'Taza decorada con flores inspirada en Crash Landing on You.', 0, 5),

(24, 'Vela - Goblin', 16.90, 5, 18,
'https://assets.printerval.com/2023/01/17/63c666068333b-1673946630.jpg',
'Vela decorativa inspirada en Goblin.', 0, 5),

(25, 'Muñeco Mang-tae - It''s Okay to Not Be Okay', 29.90, 5, 10,
'https://i.pinimg.com/736x/38/77/59/3877594fd552188a155b05e6e04769ab.jpg',
'Muñeco Mang-tae inspirado en It''s Okay to Not Be Okay.', 0, 3),

(26, 'Espejo Greystoke - Thomas & Vines', 89.90, 5, 5,
'https://cdn.tatlerasia.com/tatlerasia/i/2024/04/26153626-new-york-suite-2-copy_cover_1510x850.jpg',
'Espejo decorativo Greystoke de Thomas & Vines visto en Queen of Tears.', 0, 2),

(30, 'Set de vasos de soju coreanos', 12.90, 5, 20,
'https://tse4.mm.bing.net/th/id/OIP.bv-tUpzOr8F1tVLTvrASCQHaGM?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
'Set de vasos de soju de estilo coreano, inspirado en las características escenas de reuniones, celebraciones y comidas que aparecen habitualmente en los K-Dramas.', 0, 5);

-- =====================================================
-- INSERTAR CLIENTES
-- Los clientes deben existir previamente en auth.users.
-- El UUID de cada cliente se obtiene de auth.users
-- mediante la dirección de correo electrónico.
-- =====================================================

INSERT INTO clientes (
    pk_cliente,
    email,
    dni_cif,
    tipo,
    razon_social,
    nombres_cliente,
    apellido1_cliente,
    apellido2_cliente,
    telefono_movil,
    rol
)
SELECT
    usuarios.id,
    datos.email,
    datos.dni_cif,
    'autónomo',
    'Persona natural',
    datos.nombres_cliente,
    datos.apellido1_cliente,
    datos.apellido2_cliente,
    datos.telefono_movil,
    datos.rol
FROM (
    VALUES
        ('dayvip12369@gmail.com',             'DNI-TEST-001', 'David',      'Campos',      NULL,          '+34600205796', 'cliente'),
        ('tchambanyamicyrille@gmail.com',     'DNI-TEST-002', 'Cyrille',    'Nyami',       'Tchamba',     '+34631172184', 'cliente'),
        ('ygcgit108@gmail.com',               'DNI-TEST-003', 'Yordano',    'Gil',         'Contreras',   '+34610776573', 'cliente'),
        ('cristianrengiforen@gmail.com',      'DNI-TEST-004', 'Cristian',   'Rengifo',     NULL,          '+34662116801', 'cliente'),
        ('jenniferprat79@gmail.com',          'DNI-TEST-005', 'Jenifer',    'Gonzalez',    NULL,          '+34627310753', 'cliente'),
        ('yolandafontanillasyuste@gmail.com', 'DNI-TEST-006', 'Yolanda',    'Fontanillas', 'Yuste',       '+34649823117', 'administrador'),
        ('1moussijoelle@gmail.com',           'DNI-TEST-007', 'Joelle',     'Moussi',      'Fako',        '+34631714181', 'cliente'),
        ('naomiquitosalazar474@gmail.com',    'DNI-TEST-008', 'Naomi',      'Quito',       NULL,          '+34631134069', 'cliente'),
        ('11m11axi@gmail.com',                'DNI-TEST-009', 'Maximiliam', 'Dostmann',    NULL,          '+34644620811', 'cliente'),
        ('nataliya.yanovic@gmail.com',        'DNI-TEST-010', 'Natalia',    'Yanovic',     NULL,          '+34679781472', 'cliente'),
        ('pblcddinbox@gmail.com',             'DNI-TEST-011', 'Rita',       'de LaTorre',  NULL,          '+34653407613', 'cliente'),
        ('arcampa@gmail.com',                 'DNI-TEST-012', 'Carlota',    'Oliva',       'Fontanillas', '+34629512436', 'cliente'),
        ('foliva30@gmail.com',                'DNI-TEST-013', 'Francesc',   'Oliva',       'Seluy',       '+34685122930', 'cliente'),
        ('nievitas@gmail.com',                'DNI-TEST-014', 'Nieves',     'Yuste',       'Font',        '+34612345678', 'cliente'),
        ('nuriaseluy@gmail.com',              'DNI-TEST-015', 'Nuria',      'Seluy',       'Puig',        '+34623456789', 'cliente')
) AS datos (
    email,
    dni_cif,
    nombres_cliente,
    apellido1_cliente,
    apellido2_cliente,
    telefono_movil,
    rol
)
INNER JOIN auth.users AS usuarios
    ON LOWER(usuarios.email) = LOWER(datos.email);