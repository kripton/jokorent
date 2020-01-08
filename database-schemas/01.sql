BEGIN TRANSACTION;

-- jokorent database schema version 01
-- all dates are ISO8601
-- all "CSL" (= comma separated list(s)) also have a space at beginning and end to match "% NUM %"
--      CSLs are used to be able to Query/Filter rows where relevant items are used without fetching + parsing the JSON

-- Contains all bookings, incoming and outgoing
CREATE TABLE IF NOT EXISTS "accounting" (
	"id"	INTEGER UNIQUE,																-- 
	"date"	TEXT NOT NULL,															-- date of booking
	"amount"	REAL NOT NULL,														-- Positive = incoming, Negative = outgoing
	"description"	TEXT NOT NULL,												-- 
	"type"	TEXT,																				-- For tax-related filtering, related to "reference". Possible values: "bill", "refund", "inventory", "honorary", "staff" OR NULL for all other
	"reference"	INTEGER,																-- FOREIGN KEY. Can refer to jobs.id (type = bills || refund), inventory_items.id (type = "inventory"). OR NULL when not related to a job
	PRIMARY KEY("id")
);

-- Actual deliveries of inventory_items
-- Staff is never part of a delivery
CREATE TABLE IF NOT EXISTS "deliveries" (
	"id"	INTEGER UNIQUE,																--
	"job"	INTEGER NOT NULL,															-- jobs.id this delivery is for
	"date_packed"	TEXT NOT NULL,												-- date when this delivery was packed OR NULL when not yet packed
	"date_delivered"	TEXT,															-- date when this delivery was delivered OR NULL when not yet delivered
	"date_returned"	TEXT,																-- date when this delivery was returned OR NULL when not yet returned
	"content"	TEXT NOT NULL,														-- JSON. Used to render the delivery slip and return check slip
	"inventory_items"	TEXT,															-- CSL of inventory_items.id OR NULL when dummy delivery
	PRIMARY KEY("id"),
	FOREIGN KEY("job") REFERENCES "jobs"("id")
);

-- Jobs/Events/Productions
CREATE TABLE IF NOT EXISTS "jobs" (
	"id"	INTEGER UNIQUE,																--
	"name"	TEXT NOT NULL,															-- user-given name for that job
	"customer"	INTEGER NOT NULL,												-- customers.id that ordered this job
	"event_date_start"	TEXT NOT NULL,									-- start date of the event taking place
	"event_data_end"	TEXT NOT NULL,										-- end date of the event taking place
	"date_created"	TEXT NOT NULL,											-- date when this row was created
	"date_last_modified"	TEXT NOT NULL,								-- date this job was last modified
	"date_offered"	TEXT,																-- date when the first offer was sent to the customer. See table "offers" for multiple OR NULL when not yet offered
	"date_accepted"	TEXT,																-- date when the customer accepted the offer/job OR NULL when not yet accepted by customer
	"date_declined"	TEXT,																-- date when the customer finally declined this job OR NULL when not yet declined by customer
	"date_executed"	TEXT,																-- date when the job was executed OR NULL when not yet executed
	"date_billed"	TEXT,																	-- date when the bill was generated OR NULL when not yet billed
	"offer_billed"	INTEGER,														-- offer.id of the offer selected by the customer and that the bill was generated from
	"date_paid"	TEXT,																		-- date when the money was received from the customer. See table "accounting" with type == "bill"
	"date_refunded"	TEXT,																-- date when money was (partially) refunded to the customer. See table "accounting" with type == "refund" for multiple OR NULL when not yet redunded
	PRIMARY KEY("id"),
	FOREIGN KEY("offer_billed") REFERENCES "offers"("id"),
	FOREIGN KEY("customer") REFERENCES "customers"("id")
);

-- Text templates (LaTeX) for generating documents
CREATE TABLE IF NOT EXISTS "templates" (
	"id"	INTEGER UNIQUE,																--
	"type"	TEXT NOT NULL,															-- Possible values: "offer", "bill", "delivery_slip", "return_slip"
	"version"	INTEGER NOT NULL,													-- Version/Variant of this template type
	"content"	TEXT NOT NULL,														-- LaTeX source with placeholders for actual dynamic data
	PRIMARY KEY("id")
);

-- General settings. Key/Value pairs
-- Stores one key called "schema_version"
-- Stores one key called "user", REFERENCING one staff.id
CREATE TABLE IF NOT EXISTS "settings" (
	"key"	TEXT NOT NULL UNIQUE,													-- Key
	"value"	TEXT NOT NULL,															-- Value (JSON / String)
	PRIMARY KEY("key")
);

-- Offers generated for jobs to be sent to the customer
CREATE TABLE IF NOT EXISTS "offers" (
	"id"	INTEGER UNIQUE,																--
	"job"	INTEGER NOT NULL,															-- jobs.id this offer is for
	"date"	TEXT NOT NULL,															-- date when the offer was generated
	"content"	TEXT NOT NULL,														-- JSON. Used to render the offer document
	"inventory_items"	TEXT,															-- CSL of inventory_items.id used in this offer OR NULL for dummy/staff-only offer
	"staff"	TEXT,																				-- CSL of staff.id used in this offer OR NULL for dumm/dry-hire offers
	FOREIGN KEY("job") REFERENCES "jobs"("id"),
	PRIMARY KEY("id")
);

-- Table of customers that order jobs
CREATE TABLE IF NOT EXISTS "customers" (
	"id"	INTEGER UNIQUE,																--
	"contact"	INTEGER,																	-- contact.id
	FOREIGN KEY("contact") REFERENCES "contact"("id"),
	PRIMARY KEY("id")
);

-- Table of staff working on jobs 
CREATE TABLE IF NOT EXISTS "staff" (
	"id"	INTEGER UNIQUE,																--
	"contact"	INTEGER,																	-- contact.id
	PRIMARY KEY("id"),
	FOREIGN KEY("contact") REFERENCES "contact"("id")
);

-- Super-class of customer and staff
CREATE TABLE IF NOT EXISTS "contact" (
	"id"	INTEGER UNIQUE,
	"name"	TEXT NOT NULL,
	"surname"	TEXT NOT NULL,
	"company"	TEXT,
	"address"	TEXT,
	"email"	TEXT,
	PRIMARY KEY("id")
);

-- Models of devices (like "Shure SM58") with general info about that device
CREATE TABLE IF NOT EXISTS "inventory_models" (
	"id"	INTEGER UNIQUE,																--
	"make"	TEXT NOT NULL,															-- Make/Producer
	"name"	TEXT NOT NULL,															-- Name/model
	"type"	TEXT,																				-- "cable", "microphone", "speaker", "amp", .... Mostly used for filtering. OR NULL
	"weight"	INTEGER,																	-- weight in grams. Used to calculate summed weight of a delivery
	PRIMARY KEY("id")
);

-- Instances of inventory_models.id. One entry for each "device" in stock
CREATE TABLE IF NOT EXISTS "inventory_items" (
	"id"	INTEGER UNIQUE,																--
	"model"	INTEGER NOT NULL,														-- inventory_models.id. Defines the model/device type of this instance
	"serial"	TEXT,																			-- Serial number or any other unique identification if necessary and/or possible
	"owner"	INTEGER NOT NULL,														-- staff.id of the person owning this device. Used so we can "offer" and "deliver" items "we" don't own
	"date_start"	TEXT,																	-- Date since when this item is part of the inventory
	"date_end"	TEXT,																		-- Date when this item was removed from the inventory
	"reason_start"	TEXT,																-- Event that made this device part of the inventory. "invest", "gift", ...
	"reason_end"	TEXT,																	-- Event that made this device no longer part of the inventory. "sold", "broken", ...
	PRIMARY KEY("id"),
	FOREIGN KEY("model") REFERENCES "inventory_models"("id"),
	FOREIGN KEY("owner") REFERENCES "staff"("id")
);

-- Thanks :)
COMMIT;
