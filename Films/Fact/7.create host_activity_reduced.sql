CREATE TABLE host_activity_reduced (
    month DATE,  -- ✅ Represents the start of the month
    host TEXT,  -- ✅ The host experiencing activity
    hit_array BIGINT[],  -- ✅ Stores daily hits as an array
    unique_visitors_array BIGINT[],  -- ✅ Stores distinct visitor counts as an array
    PRIMARY KEY (month, host)  -- ✅ Ensures uniqueness at the month-host level
);
