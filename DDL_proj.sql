
-- ------------------------------------------------------------
-- TABLE: users
-- ------------------------------------------------------------
CREATE TABLE public.users (
    user_id    INTEGER                NOT NULL,
    first_name CHARACTER VARYING      NOT NULL,
    last_name  CHARACTER VARYING      NOT NULL,
    email_id   CHARACTER VARYING      NOT NULL,
    reg_date   DATE,

    CONSTRAINT users_pkey
        PRIMARY KEY (user_id),
    CONSTRAINT users_email_id_key
        UNIQUE (email_id)
);

-- ------------------------------------------------------------
-- TABLE: stations
-- ------------------------------------------------------------
CREATE TABLE public.stations (
    station_id   INTEGER           NOT NULL,
    station_name CHARACTER VARYING NOT NULL,
    capacity     INTEGER           NOT NULL,

    CONSTRAINT stations_pkey
        PRIMARY KEY (station_id),
    CONSTRAINT stations_station_name_key
        UNIQUE (station_name)
);

-- ------------------------------------------------------------
-- TABLE: bikes
-- Referenced by rides and maintenances
-- ------------------------------------------------------------
CREATE TABLE public.bikes (
    bike_id            INTEGER          NOT NULL,
    bike_type          TEXT             NOT NULL,
    bike_status        TEXT,
    current_station_id INTEGER,
    battery_level      DOUBLE PRECISION,

    CONSTRAINT bikes_pkey
        PRIMARY KEY (bike_id),
    CONSTRAINT bikes_bike_type_check
        CHECK (bike_type = ANY (ARRAY['manual', 'electric'])),
    CONSTRAINT bikes_bike_status_check
        CHECK (bike_status = ANY (ARRAY['docked', 'in use', 'under maintenance'])),
    CONSTRAINT fk_current_station_id
        FOREIGN KEY (current_station_id)
        REFERENCES public.stations (station_id)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- TABLE: rides
-- ------------------------------------------------------------
CREATE TABLE public.rides (
    ride_id      INTEGER                     NOT NULL,
    user_id      INTEGER,
    bike_id      INTEGER,
    from_station INTEGER,
    to_station   INTEGER,
    start_time   TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_time     TIMESTAMP WITHOUT TIME ZONE,
    ride_cost    DOUBLE PRECISION,
    ride_status  TEXT                        NOT NULL,
    ride_dist_km DOUBLE PRECISION,

    CONSTRAINT rides_pkey
        PRIMARY KEY (ride_id),
    CONSTRAINT rides_ride_cost_check
        CHECK (ride_cost >= 0),
    CONSTRAINT rides_ride_status_check
        CHECK (ride_status = ANY (ARRAY['ongoing', 'completed'])),
    CONSTRAINT rides_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES public.users (user_id)
        ON DELETE SET NULL,
    CONSTRAINT rides_bike_id_fkey
        FOREIGN KEY (bike_id)
        REFERENCES public.bikes (bike_id)
        ON DELETE SET NULL,
    CONSTRAINT rides_from_station_fkey
        FOREIGN KEY (from_station)
        REFERENCES public.stations (station_id)
        ON DELETE SET NULL,
    CONSTRAINT rides_to_station_fkey
        FOREIGN KEY (to_station)
        REFERENCES public.stations (station_id)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- TABLE: payments
-- ------------------------------------------------------------
CREATE TABLE public.payments (
    payment_id     INTEGER          NOT NULL,
    ride_id        INTEGER,
    amount         DOUBLE PRECISION NOT NULL,
    payment_date   DATE             NOT NULL,
    payment_status TEXT,

    CONSTRAINT payments_pkey
        PRIMARY KEY (payment_id),
    CONSTRAINT payments_payment_status_check
        CHECK (payment_status = ANY (ARRAY['success', 'failed'])),
    CONSTRAINT payments_ride_id_fkey
        FOREIGN KEY (ride_id)
        REFERENCES public.rides (ride_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- TABLE: maintenances
-- ------------------------------------------------------------
CREATE TABLE public.maintenances (
    maint_id      INTEGER NOT NULL,
    bike_id       INTEGER,
    issue         TEXT,
    reported_date DATE    NOT NULL,
    fixed_date    DATE,
    maint_status  TEXT,

    CONSTRAINT maintenances_pkey
        PRIMARY KEY (maint_id),
    CONSTRAINT maintenances_maint_status_check
        CHECK (maint_status = ANY (ARRAY['ongoing', 'done'])),
    CONSTRAINT maintenances_bike_id_fkey
        FOREIGN KEY (bike_id)
        REFERENCES public.bikes (bike_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- TABLE: subscriptions
-- ------------------------------------------------------------
CREATE TABLE public.subscriptions (
    sub_id         INTEGER NOT NULL,
    user_id        INTEGER,
    sub_type       TEXT,
    beginning_date DATE    NOT NULL,
    end_date       DATE,

    CONSTRAINT subscriptions_pkey
        PRIMARY KEY (sub_id),
    CONSTRAINT subscriptions_sub_type_check
        CHECK (sub_type = ANY (ARRAY['monthly', 'yearly', 'quarterly'])),
    CONSTRAINT subscriptions_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES public.users (user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_sub_type
        FOREIGN KEY (sub_type)
        REFERENCES public.subscription_types (sub_type)
        ON DELETE RESTRICT
);
-- ------------------------------------------------------------
-- TABLE: subscription_types
-- ------------------------------------------------------------
CREATE TABLE public.subscription_types (
    sub_type  TEXT        NOT NULL,
    cost      NUMERIC     NOT NULL,

    CONSTRAINT subscription_types_pkey
        PRIMARY KEY (sub_type),
    CONSTRAINT subscription_types_sub_type_check
        CHECK (sub_type = ANY (ARRAY['monthly', 'quarterly', 'yearly']))
);
