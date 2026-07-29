--
-- PostgreSQL database dump
--

\restrict zANUacfViIMs3itpng4AKkRhFwBwsJWZklAXPngtvnQegP4edRli7vdwW91THyA

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-07-29 16:32:18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 242 (class 1255 OID 16818)
-- Name: calculate_inventory_value(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_inventory_value() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_value NUMERIC(14, 2);
BEGIN
    SELECT COALESCE(
        SUM(i.quantity_in_stock * p.cost_price),
        0
    )
    INTO total_value
    FROM inventory i
    JOIN products p
        ON i.product_id = p.product_id;

    RETURN total_value;
END;
$$;


ALTER FUNCTION public.calculate_inventory_value() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16811)
-- Name: reduce_inventory_after_order(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reduce_inventory_after_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    current_stock INT;
BEGIN
    SELECT quantity_in_stock
    INTO current_stock
    FROM inventory
    WHERE product_id = NEW.product_id
      AND warehouse_id = 1;

    IF current_stock IS NULL THEN
        RAISE EXCEPTION
            'Product % does not exist in warehouse 1 inventory',
            NEW.product_id;
    END IF;

    IF current_stock < NEW.quantity THEN
        RAISE EXCEPTION
            'Not enough inventory for product %. Available: %, requested: %',
            NEW.product_id,
            current_stock,
            NEW.quantity;
    END IF;

    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock - NEW.quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id
      AND warehouse_id = 1;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.reduce_inventory_after_order() OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16819)
-- Name: restock_product(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.restock_product(IN p_product_id integer, IN p_warehouse_id integer, IN p_quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE inventory
    SET quantity_in_stock = quantity_in_stock + p_quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id
      AND warehouse_id = p_warehouse_id;
END;
$$;


ALTER PROCEDURE public.restock_product(IN p_product_id integer, IN p_warehouse_id integer, IN p_quantity integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16585)
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16584)
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 219
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- TOC entry 226 (class 1259 OID 16651)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(150),
    phone character varying(30),
    address character varying(255),
    city character varying(100),
    state character varying(50),
    zip_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16650)
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customer_id_seq OWNER TO postgres;

--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 225
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- TOC entry 230 (class 1259 OID 16680)
-- Name: inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory (
    inventory_id integer NOT NULL,
    product_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    quantity_in_stock integer DEFAULT 0 NOT NULL,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT inventory_quantity_in_stock_check CHECK ((quantity_in_stock >= 0))
);


ALTER TABLE public.inventory OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16679)
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_inventory_id_seq OWNER TO postgres;

--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 229
-- Name: inventory_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_inventory_id_seq OWNED BY public.inventory.inventory_id;


--
-- TOC entry 224 (class 1259 OID 16613)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    category_id integer NOT NULL,
    supplier_id integer NOT NULL,
    product_name character varying(150) NOT NULL,
    sku character varying(50) NOT NULL,
    description text,
    cost_price numeric(10,2) NOT NULL,
    selling_price numeric(10,2) NOT NULL,
    reorder_level integer DEFAULT 5 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_product_price CHECK ((selling_price >= cost_price)),
    CONSTRAINT products_cost_price_check CHECK ((cost_price >= (0)::numeric)),
    CONSTRAINT products_reorder_level_check CHECK ((reorder_level >= 0)),
    CONSTRAINT products_selling_price_check CHECK ((selling_price >= (0)::numeric))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16666)
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    warehouse_id integer NOT NULL,
    warehouse_name character varying(150) NOT NULL,
    address character varying(255),
    city character varying(100),
    state character varying(50),
    zip_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16801)
-- Name: inventory_report_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.inventory_report_view AS
 SELECT p.product_id,
    p.product_name,
    p.sku,
    w.warehouse_name,
    i.quantity_in_stock,
    p.reorder_level,
        CASE
            WHEN (i.quantity_in_stock <= p.reorder_level) THEN 'Low Stock'::text
            ELSE 'In Stock'::text
        END AS stock_status
   FROM ((public.inventory i
     JOIN public.products p ON ((i.product_id = p.product_id)))
     JOIN public.warehouses w ON ((i.warehouse_id = w.warehouse_id)));


ALTER VIEW public.inventory_report_view OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16813)
-- Name: low_stock_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.low_stock_view AS
 SELECT p.product_id,
    p.product_name,
    p.sku,
    w.warehouse_name,
    i.quantity_in_stock,
    p.reorder_level
   FROM ((public.inventory i
     JOIN public.products p ON ((i.product_id = p.product_id)))
     JOIN public.warehouses w ON ((i.warehouse_id = w.warehouse_id)))
  WHERE (i.quantity_in_stock <= p.reorder_level);


ALTER VIEW public.low_stock_view OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16737)
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    line_total numeric(12,2) GENERATED ALWAYS AS (((quantity)::numeric * unit_price)) STORED,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16706)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    order_status character varying(30) DEFAULT 'Pending'::character varying NOT NULL,
    shipping_address character varying(255) NOT NULL,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(12,2) DEFAULT 0 NOT NULL,
    shipping_cost numeric(12,2) DEFAULT 0 NOT NULL,
    total_amount numeric(12,2) DEFAULT 0 NOT NULL,
    CONSTRAINT orders_order_status_check CHECK (((order_status)::text = ANY ((ARRAY['Pending'::character varying, 'Processing'::character varying, 'Shipped'::character varying, 'Delivered'::character varying, 'Cancelled'::character varying])::text[]))),
    CONSTRAINT orders_shipping_cost_check CHECK ((shipping_cost >= (0)::numeric)),
    CONSTRAINT orders_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT orders_tax_amount_check CHECK ((tax_amount >= (0)::numeric)),
    CONSTRAINT orders_total_amount_check CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16806)
-- Name: order_details_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.order_details_view AS
 SELECT o.order_id,
    (((c.first_name)::text || ' '::text) || (c.last_name)::text) AS customer,
    o.order_date,
    o.order_status,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total,
    o.total_amount
   FROM (((public.orders o
     JOIN public.customers c ON ((o.customer_id = c.customer_id)))
     JOIN public.order_items oi ON ((o.order_id = oi.order_id)))
     JOIN public.products p ON ((oi.product_id = p.product_id)));


ALTER VIEW public.order_details_view OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16736)
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- TOC entry 231 (class 1259 OID 16705)
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- TOC entry 236 (class 1259 OID 16764)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id integer NOT NULL,
    order_id integer NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    payment_method character varying(30) NOT NULL,
    payment_status character varying(30) DEFAULT 'Pending'::character varying NOT NULL,
    amount numeric(12,2) NOT NULL,
    transaction_reference character varying(100),
    CONSTRAINT payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payments_payment_method_check CHECK (((payment_method)::text = ANY ((ARRAY['Credit Card'::character varying, 'Debit Card'::character varying, 'PayPal'::character varying, 'Cash'::character varying, 'Bank Transfer'::character varying])::text[]))),
    CONSTRAINT payments_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['Pending'::character varying, 'Completed'::character varying, 'Failed'::character varying, 'Refunded'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16763)
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_payment_id_seq OWNER TO postgres;

--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 235
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- TOC entry 222 (class 1259 OID 16599)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    company_name character varying(150) NOT NULL,
    contact_name character varying(100),
    email character varying(150),
    phone character varying(30),
    address character varying(255),
    city character varying(100),
    state character varying(50),
    zip_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16796)
-- Name: product_details_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.product_details_view AS
 SELECT p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    s.company_name AS supplier,
    p.cost_price,
    p.selling_price,
    p.reorder_level,
    p.is_active
   FROM ((public.products p
     JOIN public.categories c ON ((p.category_id = c.category_id)))
     JOIN public.suppliers s ON ((p.supplier_id = s.supplier_id)));


ALTER VIEW public.product_details_view OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16612)
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO postgres;

--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- TOC entry 221 (class 1259 OID 16598)
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_supplier_id_seq OWNER TO postgres;

--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 221
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;


--
-- TOC entry 227 (class 1259 OID 16665)
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_warehouse_id_seq OWNER TO postgres;

--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 227
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_warehouse_id_seq OWNED BY public.warehouses.warehouse_id;


--
-- TOC entry 4915 (class 2604 OID 16588)
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- TOC entry 4924 (class 2604 OID 16654)
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- TOC entry 4928 (class 2604 OID 16683)
-- Name: inventory inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory ALTER COLUMN inventory_id SET DEFAULT nextval('public.inventory_inventory_id_seq'::regclass);


--
-- TOC entry 4938 (class 2604 OID 16740)
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- TOC entry 4931 (class 2604 OID 16709)
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- TOC entry 4940 (class 2604 OID 16767)
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- TOC entry 4919 (class 2604 OID 16616)
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 16602)
-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);


--
-- TOC entry 4926 (class 2604 OID 16669)
-- Name: warehouses warehouse_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN warehouse_id SET DEFAULT nextval('public.warehouses_warehouse_id_seq'::regclass);


--
-- TOC entry 5163 (class 0 OID 16585)
-- Dependencies: 220
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (category_id, category_name, description, created_at) FROM stdin;
1	Electronics	Electronic devices and computer accessories	2026-07-29 15:48:23.574546
2	Office Supplies	Products and supplies used in offices	2026-07-29 15:48:23.574546
3	Furniture	Office and home furniture	2026-07-29 15:48:23.574546
4	Clothing	Business and casual clothing	2026-07-29 15:48:23.574546
\.


--
-- TOC entry 5169 (class 0 OID 16651)
-- Dependencies: 226
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (customer_id, first_name, last_name, email, phone, address, city, state, zip_code, created_at) FROM stdin;
1	David	Wilson	david.wilson@email.com	814-555-2001	123 Main Street	Erie	PA	16501	2026-07-29 15:48:23.574546
2	Sarah	Johnson	sarah.johnson@email.com	412-555-2002	45 Liberty Avenue	Pittsburgh	PA	15201	2026-07-29 15:48:23.574546
3	Michael	Brown	michael.brown@email.com	216-555-2003	78 Market Street	Cleveland	OH	44101	2026-07-29 15:48:23.574546
4	Jessica	Miller	jessica.miller@email.com	814-555-2004	900 Peach Street	Erie	PA	16502	2026-07-29 15:48:23.574546
\.


--
-- TOC entry 5173 (class 0 OID 16680)
-- Dependencies: 230
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory (inventory_id, product_id, warehouse_id, quantity_in_stock, last_updated) FROM stdin;
1	1	1	40	2026-07-29 15:48:23.574546
2	2	1	20	2026-07-29 15:48:23.574546
4	4	1	100	2026-07-29 15:48:23.574546
5	5	1	60	2026-07-29 15:48:23.574546
6	6	1	12	2026-07-29 15:48:23.574546
8	8	1	50	2026-07-29 15:48:23.574546
9	1	2	25	2026-07-29 15:48:23.574546
10	2	2	15	2026-07-29 15:48:23.574546
11	3	2	18	2026-07-29 15:48:23.574546
12	4	2	80	2026-07-29 15:48:23.574546
13	5	2	45	2026-07-29 15:48:23.574546
14	6	2	8	2026-07-29 15:48:23.574546
15	7	2	4	2026-07-29 15:48:23.574546
16	8	2	30	2026-07-29 15:48:23.574546
7	7	1	2	2026-07-29 15:48:23.574546
3	3	1	34	2026-07-29 16:06:09.622428
\.


--
-- TOC entry 5177 (class 0 OID 16737)
-- Dependencies: 234
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_item_id, order_id, product_id, quantity, unit_price) FROM stdin;
1	1	1	1	24.99
2	1	2	1	79.99
3	2	4	1	8.99
4	2	6	1	149.99
5	3	7	1	249.99
6	4	3	1	44.99
\.


--
-- TOC entry 5175 (class 0 OID 16706)
-- Dependencies: 232
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, customer_id, order_date, order_status, shipping_address, subtotal, tax_amount, shipping_cost, total_amount) FROM stdin;
1	1	2026-07-29 15:48:23.574546	Delivered	123 Main Street, Erie, PA 16501	104.97	6.30	5.00	116.27
2	2	2026-07-29 15:48:23.574546	Processing	45 Liberty Avenue, Pittsburgh, PA 15201	158.98	9.54	10.00	178.52
3	3	2026-07-29 15:48:23.574546	Pending	78 Market Street, Cleveland, OH 44101	249.99	15.00	15.00	279.99
4	4	2026-07-29 16:00:44.701291	Pending	900 Peach Street, Erie, PA 16502	44.99	2.70	5.00	52.69
5	4	2026-07-29 16:01:14.074054	Pending	900 Peach Street, Erie, PA 16502	44.99	2.70	5.00	52.69
\.


--
-- TOC entry 5179 (class 0 OID 16764)
-- Dependencies: 236
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, order_id, payment_date, payment_method, payment_status, amount, transaction_reference) FROM stdin;
1	1	2026-07-29 15:48:23.574546	Credit Card	Completed	116.27	TXN-2026-0001
2	2	2026-07-29 15:48:23.574546	PayPal	Completed	178.52	TXN-2026-0002
3	3	2026-07-29 15:48:23.574546	Debit Card	Pending	279.99	TXN-2026-0003
\.


--
-- TOC entry 5167 (class 0 OID 16613)
-- Dependencies: 224
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, category_id, supplier_id, product_name, sku, description, cost_price, selling_price, reorder_level, is_active, created_at, updated_at) FROM stdin;
1	1	1	Wireless Mouse	ELEC-001	Wireless optical computer mouse	12.50	24.99	10	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
2	1	1	Mechanical Keyboard	ELEC-002	Mechanical keyboard with LED backlight	45.00	79.99	5	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
3	1	1	USB-C Hub	ELEC-003	Seven-port USB-C connection hub	24.00	44.99	8	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
4	2	2	Printer Paper	OFF-001	Package containing 500 sheets	4.25	8.99	20	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
5	2	2	Ballpoint Pens	OFF-002	Package of twelve blue ballpoint pens	3.00	6.99	15	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
6	3	3	Office Chair	FURN-001	Adjustable ergonomic office chair	85.00	149.99	3	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
7	3	3	Office Desk	FURN-002	Modern wooden office desk	140.00	249.99	2	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
8	4	4	Company T-Shirt	CLOTH-001	Cotton company-branded T-shirt	8.00	19.99	10	t	2026-07-29 15:48:23.574546	2026-07-29 15:48:23.574546
\.


--
-- TOC entry 5165 (class 0 OID 16599)
-- Dependencies: 222
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (supplier_id, company_name, contact_name, email, phone, address, city, state, zip_code, created_at) FROM stdin;
1	TechSource LLC	John Smith	john@techsource.com	814-555-1001	1200 Technology Drive	Erie	PA	16501	2026-07-29 15:48:23.574546
2	Office World	Sarah Johnson	sarah@officeworld.com	814-555-1002	450 Business Avenue	Pittsburgh	PA	15201	2026-07-29 15:48:23.574546
3	Furniture Direct	Michael Brown	michael@furnituredirect.com	216-555-1003	800 Market Street	Cleveland	OH	44101	2026-07-29 15:48:23.574546
4	Style Supply Company	Emily Davis	emily@stylesupply.com	412-555-1004	500 Fashion Boulevard	Pittsburgh	PA	15222	2026-07-29 15:48:23.574546
\.


--
-- TOC entry 5171 (class 0 OID 16666)
-- Dependencies: 228
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (warehouse_id, warehouse_name, address, city, state, zip_code, created_at) FROM stdin;
1	Erie Main Warehouse	2000 Industrial Drive	Erie	PA	16510	2026-07-29 15:48:23.574546
2	Pittsburgh Distribution Center	4500 Commerce Road	Pittsburgh	PA	15222	2026-07-29 15:48:23.574546
\.


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 219
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 4, true);


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 225
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 4, true);


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 229
-- Name: inventory_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_inventory_id_seq', 16, true);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 233
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 6, true);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 231
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 5, true);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 235
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 3, true);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_product_id_seq', 8, true);


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 221
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suppliers_supplier_id_seq', 4, true);


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 227
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_warehouse_id_seq', 2, true);


--
-- TOC entry 4959 (class 2606 OID 16597)
-- Name: categories categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);


--
-- TOC entry 4961 (class 2606 OID 16595)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4974 (class 2606 OID 16664)
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- TOC entry 4976 (class 2606 OID 16662)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 4984 (class 2606 OID 16692)
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id);


--
-- TOC entry 4994 (class 2606 OID 16750)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- TOC entry 4990 (class 2606 OID 16730)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- TOC entry 4999 (class 2606 OID 16779)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 5001 (class 2606 OID 16781)
-- Name: payments payments_transaction_reference_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_transaction_reference_key UNIQUE (transaction_reference);


--
-- TOC entry 4970 (class 2606 OID 16637)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- TOC entry 4972 (class 2606 OID 16639)
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- TOC entry 4963 (class 2606 OID 16611)
-- Name: suppliers suppliers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_email_key UNIQUE (email);


--
-- TOC entry 4965 (class 2606 OID 16609)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- TOC entry 4996 (class 2606 OID 16752)
-- Name: order_items unique_order_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT unique_order_product UNIQUE (order_id, product_id);


--
-- TOC entry 4986 (class 2606 OID 16694)
-- Name: inventory unique_product_warehouse; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT unique_product_warehouse UNIQUE (product_id, warehouse_id);


--
-- TOC entry 4978 (class 2606 OID 16676)
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- TOC entry 4980 (class 2606 OID 16678)
-- Name: warehouses warehouses_warehouse_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_warehouse_name_key UNIQUE (warehouse_name);


--
-- TOC entry 4981 (class 1259 OID 16790)
-- Name: idx_inventory_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_product ON public.inventory USING btree (product_id);


--
-- TOC entry 4982 (class 1259 OID 16820)
-- Name: idx_inventory_warehouse; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_inventory_warehouse ON public.inventory USING btree (warehouse_id);


--
-- TOC entry 4991 (class 1259 OID 16793)
-- Name: idx_order_items_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order ON public.order_items USING btree (order_id);


--
-- TOC entry 4992 (class 1259 OID 16794)
-- Name: idx_order_items_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_product ON public.order_items USING btree (product_id);


--
-- TOC entry 4987 (class 1259 OID 16791)
-- Name: idx_orders_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_customer ON public.orders USING btree (customer_id);


--
-- TOC entry 4988 (class 1259 OID 16792)
-- Name: idx_orders_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_date ON public.orders USING btree (order_date);


--
-- TOC entry 4997 (class 1259 OID 16795)
-- Name: idx_payments_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_payments_order ON public.payments USING btree (order_id);


--
-- TOC entry 4966 (class 1259 OID 16787)
-- Name: idx_products_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_category ON public.products USING btree (category_id);


--
-- TOC entry 4967 (class 1259 OID 16789)
-- Name: idx_products_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_name ON public.products USING btree (product_name);


--
-- TOC entry 4968 (class 1259 OID 16788)
-- Name: idx_products_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_supplier ON public.products USING btree (supplier_id);


--
-- TOC entry 5010 (class 2620 OID 16812)
-- Name: order_items trg_reduce_inventory_after_order; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_reduce_inventory_after_order AFTER INSERT ON public.order_items FOR EACH ROW EXECUTE FUNCTION public.reduce_inventory_after_order();


--
-- TOC entry 5004 (class 2606 OID 16695)
-- Name: inventory fk_inventory_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5005 (class 2606 OID 16700)
-- Name: inventory fk_inventory_warehouse; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT fk_inventory_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(warehouse_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5006 (class 2606 OID 16731)
-- Name: orders fk_order_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 5007 (class 2606 OID 16753)
-- Name: order_items fk_order_item_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5008 (class 2606 OID 16758)
-- Name: order_items fk_order_item_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 5009 (class 2606 OID 16782)
-- Name: payments fk_payment_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5002 (class 2606 OID 16640)
-- Name: products fk_product_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 5003 (class 2606 OID 16645)
-- Name: products fk_product_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_product_supplier FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2026-07-29 16:32:18

--
-- PostgreSQL database dump complete
--

\unrestrict zANUacfViIMs3itpng4AKkRhFwBwsJWZklAXPngtvnQegP4edRli7vdwW91THyA

