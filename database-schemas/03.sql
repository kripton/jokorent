BEGIN TRANSACTION;

-- jokorent database schema version 01
-- all dates are ISO8601

-- Contains all bookings, incoming and outgoing
CREATE TABLE IF NOT EXISTS "accounting" (
  "id" INTEGER UNIQUE,                         --
  "date" TEXT NOT NULL,                        -- date of booking
  "amount" REAL NOT NULL,                      -- Positive = incoming, Negative = outgoing
  "description" TEXT NOT NULL,                 --
  "type" TEXT,                                 -- For tax-related filtering, related to "reference". Possible values: "bill", "refund", "inventory", "honorary", "staff" OR NULL for all other
  "reference" INTEGER,                         -- FOREIGN KEY. Can refer to bills.id (type = bills), refunds.id (type = refund), inventoryItems.id (type = inventory). OR NULL when not related to a job
  PRIMARY KEY("id")
);

-- Actual deliveries of inventoryItems
-- Staff is never part of a delivery
CREATE TABLE IF NOT EXISTS "deliveries" (
  "id" INTEGER UNIQUE,                         --
  "job" INTEGER NOT NULL,                      -- jobs.id this delivery is for
  "date_packed" TEXT NOT NULL,                 -- date when this delivery was packed OR NULL when not yet packed
  "date_delivered" TEXT,                       -- date when this delivery was delivered OR NULL when not yet delivered
  "date_returned" TEXT,                        -- date when this delivery was returned OR NULL when not yet returned
  "content" TEXT NOT NULL,                     -- JSON. Used to render the delivery slip and return check slip
  PRIMARY KEY("id"),
  FOREIGN KEY("job") REFERENCES "jobs"("id")
);

-- Relating inventoryItems used in deliveries
CREATE TABLE IF NOT EXISTS "inventoryItems_in_deliveries" (
  "id" INTEGER UNIQUE,
  "delivery" INTEGER NOT NULL,                 -- deliveries.id of the delivery using the item
  "inventoryItem" INTEGER NOT NULL,            -- inventoryItems.id of the item being used
  PRIMARY KEY("id"),
  FOREIGN KEY("delivery") REFERENCES "deliveries"("id"),
  FOREIGN KEY("inventoryItem") REFERENCES "inventoryItems"("id")
);

-- Jobs/Events/Productions
CREATE TABLE IF NOT EXISTS "jobs" (
  "id" INTEGER UNIQUE,                         --
  "name" TEXT NOT NULL,                        -- user-given name for that job
  "customer" INTEGER NOT NULL,                 -- customers.id that ordered this job
  "event_date_start" TEXT NOT NULL,            -- start date of the event taking place
  "event_data_end" TEXT NOT NULL,              -- end date of the event taking place
  "date_created" TEXT NOT NULL,                -- date when this row was created
  "date_last_modified" TEXT NOT NULL,          -- date this job was last modified
  "date_executed" TEXT,                        -- date when the job was executed OR NULL when not yet executed
  PRIMARY KEY("id"),
  FOREIGN KEY("customer") REFERENCES "customers"("id")
);

-- Text templates (LaTeX) for generating documents
CREATE TABLE IF NOT EXISTS "templates" (
  "id" INTEGER UNIQUE,                         --
  "type" TEXT NOT NULL,                        -- Possible values: "offer", "bill", "refund", "delivery_slip", "return_slip"
  "version" INTEGER NOT NULL,                  -- Version/Variant of this template type
  "content" TEXT NOT NULL,                     -- LaTeX source with placeholders for actual dynamic data
  PRIMARY KEY("id")
);

-- General settings. Key/Value pairs
-- Stores one key called "schema_version"
-- Stores one key called "user", REFERENCING one staff.id
CREATE TABLE IF NOT EXISTS "settings" (
  "key" TEXT NOT NULL UNIQUE,                  -- Key
  "value" TEXT NOT NULL,                       -- Value (JSON / String)
  PRIMARY KEY("key")
);

-- Offers generated for jobs to be sent to the customer
CREATE TABLE IF NOT EXISTS "offers" (
  "id" INTEGER UNIQUE,                         --
  "job" INTEGER NOT NULL,                      -- jobs.id this offer is for
  "date_generated" TEXT NOT NULL,              -- date when the offer was generated
  "date_accepted" TEXT,                        -- date when the customer accepted the offer OR NULL when not yet accepted by customer
  "date_declined" TEXT,                        -- date when the customer declined this offer OR NULL when not yet declined by customer
  "content" TEXT NOT NULL,                     -- JSON. Used to render the offer document
  FOREIGN KEY("job") REFERENCES "jobs"("id"),
  PRIMARY KEY("id")
);

-- Relating inventoryItems used in offers
CREATE TABLE IF NOT EXISTS "inventoryItems_in_offers" (
  "id" INTEGER UNIQUE,
  "offer" INTEGER NOT NULL,                    -- offers.id of the offer using the item
  "inventoryItem" INTEGER NOT NULL,            -- inventoryItems.id of the item being used
  PRIMARY KEY("id"),
  FOREIGN KEY("offer") REFERENCES "offers"("id"),
  FOREIGN KEY("inventoryItem") REFERENCES "inventoryItems"("id")
);

-- Relating staff used in offers
CREATE TABLE IF NOT EXISTS "staff_in_offers" (
  "id" INTEGER UNIQUE,
  "offer" INTEGER NOT NULL,                    -- offers.id of the offer using the staff
  "staff" INTEGER NOT NULL,                    -- staff.id of the staff being planned
  PRIMARY KEY("id"),
  FOREIGN KEY("offer") REFERENCES "offers"("id"),
  FOREIGN KEY("staff") REFERENCES "staff"("id")
);

-- Bills generated for jobs to be sent to the customer
CREATE TABLE IF NOT EXISTS "bills" (
  "id" INTEGER UNIQUE,                         --
  "job" INTEGER NOT NULL,                      -- jobs.id this offer is for
  "offer" INTEGER,                             -- offer.is this bill has been generated from. Can be NULL for bills not derived from an offer
  "date_generated" TEXT NOT NULL,              -- date when the bill was generated
  "date_paid" TEXT,                            -- date when the customer paid the bill. See table "accounting" with type == "bill"
  "content" TEXT NOT NULL,                     -- JSON. Used to render the bill document
  FOREIGN KEY("job") REFERENCES "jobs"("id"),
  FOREIGN KEY("offer") REFERENCES "offers"("id"),
  PRIMARY KEY("id")
);

-- Relating inventoryItems used in bills
CREATE TABLE IF NOT EXISTS "inventoryItems_in_bills" (
  "id" INTEGER UNIQUE,
  "bill" INTEGER NOT NULL,                     -- bill.id of the offer using the item
  "inventoryItem" INTEGER NOT NULL,            -- inventoryItems.id of the item being used
  PRIMARY KEY("id"),
  FOREIGN KEY("bill") REFERENCES "offers"("bills"),
  FOREIGN KEY("inventoryItem") REFERENCES "inventoryItems"("id")
);

-- Relating staff used in bills
CREATE TABLE IF NOT EXISTS "staff_in_bills" (
  "id" INTEGER UNIQUE,
  "bill" INTEGER NOT NULL,                     -- bills.id of the offer using the staff
  "staff" INTEGER NOT NULL,                    -- staff.id of the staff being planned
  PRIMARY KEY("id"),
  FOREIGN KEY("bill") REFERENCES "bills"("id"),
  FOREIGN KEY("staff") REFERENCES "staff"("id")
);

-- Refunds generated for bills to be sent to the customer
CREATE TABLE IF NOT EXISTS "refunds" (
  "id" INTEGER UNIQUE,                         --
  "bill" INTEGER NOT NULL,                     -- bills.id this refund is for
  "date_generated" TEXT NOT NULL,              -- date when the refund was generated
  "date_paid" TEXT,                            -- date when the money was given/paid to the customer. See table "accounting" with type == "refund"
  FOREIGN KEY("bill") REFERENCES "bills"("id"),
  PRIMARY KEY("id")
);

-- Table of customers that order jobs
CREATE TABLE IF NOT EXISTS "customers" (
  "id" INTEGER UNIQUE,                         --
  "contact" INTEGER,                           -- contact.id
  FOREIGN KEY("contact") REFERENCES "contact"("id"),
  PRIMARY KEY("id")
);

-- Table of staff working on jobs 
CREATE TABLE IF NOT EXISTS "staff" (
  "id" INTEGER UNIQUE,                         --
  "contact" INTEGER,                           -- contact.id
  PRIMARY KEY("id"),
  FOREIGN KEY("contact") REFERENCES "contact"("id")
);

-- Super-class of customer and staff
CREATE TABLE IF NOT EXISTS "contact" (
  "id" INTEGER UNIQUE,                         --
  "name" TEXT NOT NULL,                        -- Family name
  "surname" TEXT NOT NULL,                     -- Surname
  "company" TEXT,                              -- Company name OR NULL
  "address" TEXT,                              -- Complete address lines OR NULL
  "email" TEXT,                                -- E-Mail-Address OR NULL
  PRIMARY KEY("id")
);

-- Models of devices (like "Shure SM58") with general info about that device
CREATE TABLE IF NOT EXISTS "inventoryModels" (
  "id" INTEGER UNIQUE,                         --
  "make" TEXT NOT NULL,                        -- Make/Producer
  "name" TEXT NOT NULL,                        -- Name/model
  "type" TEXT,                                 -- "cable", "microphone", "speaker", "amp", .... Mostly used for filtering. OR NULL
  "weight" INTEGER,                            -- weight in kilograms. Used to calculate summed weight of a delivery
  PRIMARY KEY("id")
);

-- Instances of inventoryModels.id. One entry for each "device" in stock
CREATE TABLE IF NOT EXISTS "inventoryItems" (
  "id" INTEGER UNIQUE,                         --
  "model" INTEGER NOT NULL,                    -- inventoryModels.id. Defines the model/device type of this instance
  "serial" TEXT,                               -- Serial number or any other unique identification if necessary and/or possible
  "owner" INTEGER NOT NULL,                    -- staff.id of the person owning this device. Used so we can "offer" and "deliver" items "we" don't own
  "comment" TEXT,                              -- Comment about that specific item (condition, unique features, problems in the past, ...)
  "date_start" TEXT,                           -- Date since when this item is part of the inventory
  "date_end" TEXT,                             -- Date when this item was removed from the inventory
  "reason_start" TEXT,                         -- Event that made this device part of the inventory. "invest", "gift", ...
  "reason_end" TEXT,                           -- Event that made this device no longer part of the inventory. "sold", "broken", ...
  PRIMARY KEY("id"),
  FOREIGN KEY("model") REFERENCES "inventoryModels"("id"),
  FOREIGN KEY("owner") REFERENCES "staff"("id")
);

-- Thanks :)
COMMIT;
