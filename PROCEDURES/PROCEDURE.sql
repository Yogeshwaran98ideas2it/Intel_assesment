CREATE OR REPLACE PROCEDURE update_order_amounts()
    RETURNS VARCHAR
    LANGUAGE SQL
AS
$$
DECLARE
    total_detail_amount NUMERIC(12,2);
    total_header_amount NUMERIC(12,2);
BEGIN
    -- Calculate total amount for each order detail and update ORDER_DETAIL
    UPDATE ORDER_BASE.ORDER_DETAIL
    SET TOTAL_AMOUNT = QTY * PRICE;

    -- Calculate total amount for each customer and update ORDER_HEADER
    UPDATE ORDER_BASE.ORDER_HEADER oh
    SET oh.TOTAL_AMOUNT = (
        SELECT SUM(OD.TOTAL_AMOUNT) 
        FROM ORDER_BASE.ORDER_DETAIL OD
        WHERE OD.CUSTOMER_ID = oh.CUSTOMER_ID
    );

    -- Get the total amount for all order details
    SELECT SUM(QTY * PRICE) INTO total_detail_amount
    FROM ORDER_BASE.ORDER_DETAIL;

    -- Get the total amount for all order headers
    SELECT SUM(TOTAL_AMOUNT) INTO total_header_amount
    FROM ORDER_BASE.ORDER_HEADER;

    RETURN 'Total amount updated successfully. New total detail amount: ' || total_detail_amount || ', New total header amount: ' || total_header_amount;
END;
$$;



-- ATE OR REPLACE PROCEDURE update_total_amount()
--     RETURNS STRING
--     LANGUAGE SQL
--     AS
-- $$
-- BEGIN
--     -- Update order_header discount based on promotion
--     UPDATE ORDER_BASE.ORDER_HEADER
--     SET DISCOUNT = 
--     (CASE
--         WHEN oh.TOTAL_AMOUNT < 1000 
--              AND p.CUSTOMER_CATEGORY IN ('Gold', 'Silver', 'Bronze') 
--              AND c.CUSTOMER_ID = oh.CUSTOMER_ID 
--              AND p.CUSTOMER_CATEGORY = c.CATEGORY 
--                 AND oh.COUPON_CODE = 'Discount'
--                    AND p.PROMOTION_TYPE = oh.COUPON_CODE
--                 THEN p.PROMOTION_VALUE * oh.TOTAL_AMOUNT
--         WHEN oh.COUPON_CODE IN ('Coupon_x', 'Coupon_y', 'Coupon_z') 
--              AND oh.CUSTOMER_ID = c.CUSTOMER_ID 
--                 AND oh.COUPON_CODE = 'Discount'
--                 THEN oh.TOTAL_AMOUNT - (oh.TOTAL_AMOUNT * p.PROMOTION_VALUE)
--         ELSE 0
--         END)
--     FROM ORDER_BASE.ORDER_HEADER oh
--     JOIN ORDER_BASE.CUSTOMER c ON oh.CUSTOMER_ID = c.CUSTOMER_ID
--     JOIN ORDER_BASE.PROMOTION p ON p.CUSTOMER_CATEGORY = c.CATEGORY
--     WHERE oh.CUSTOMER_ID = c.CUSTOMER_ID;

--     CALL update_order_amounts();

--     RETURN 'Total amounts updated successfully';
-- END;
-- $$;

-- CREATE OR REPLACE PROCEDURE update_total_amount()
--     RETURNS STRING
--     LANGUAGE SQL
--     AS
-- $$
-- BEGIN
--     -- Update order_header discount based on promotion
--     UPDATE ORDER_BASE.ORDER_HEADER
--     SET DISCOUNT = 
--     (CASE
--         WHEN oh.TOTAL_AMOUNT < 1000 
--              AND p.CUSTOMER_CATEGORY IN ('Gold', 'Silver', 'Bronze') 
--              AND c.CUSTOMER_ID = oh.CUSTOMER_ID 
--              AND p.CUSTOMER_CATEGORY = c.CATEGORY 
--                 AND oh.COUPON_CODE = 'Discount'
--                    AND p.PROMOTION_TYPE = oh.COUPON_CODE
--                 THEN p.PROMOTION_VALUE * oh.TOTAL_AMOUNT
--         WHEN oh.COUPON_CODE IN ('Coupon_x', 'Coupon_y', 'Coupon_z') 
--              AND oh.CUSTOMER_ID = c.CUSTOMER_ID 
--                 AND oh.COUPON_CODE = 'Discount'
--                 THEN oh.TOTAL_AMOUNT - (oh.TOTAL_AMOUNT * p.PROMOTION_VALUE)
        
--         ELSE 0
--         END)
--     FROM ORDER_BASE.ORDER_HEADER oh
--     JOIN ORDER_BASE.CUSTOMER c ON oh.CUSTOMER_ID = c.CUSTOMER_ID
--     JOIN ORDER_BASE.PROMOTION p ON p.CUSTOMER_CATEGORY = c.CATEGORY
--     WHERE oh.CUSTOMER_ID = c.CUSTOMER_ID;

--     UPDATE ORDER_BASE.CUSTOMER c
--     SET LOYALTY_POINTS = p.PROMOTION_VALUE + LOYALTY_POINTS
--     FROM ORDER_BASE.PROMOTION p
--     WHERE c.CUSTOMER_ID IN (
--     SELECT oh.CUSTOMER_ID
--     FROM ORDER_BASE.ORDER_HEADER oh
--     WHERE oh.TOTAL_AMOUNT > 1000
--         AND p.CUSTOMER_CATEGORY IN ('Gold', 'Silver', 'Bronze') 
--         AND oh.COUPON_CODE = 'Loyalty'
--         AND p.PROMOTION_TYPE = oh.COUPON_CODE

--     CALL update_order_amounts();
-- -     RETURN 'Total amounts updated successfully';
-- END;
-- $$;

CREATE OR REPLACE PROCEDURE INTEL_ASSESMENT.ORDER_BASE.UPDATE_TOTAL_AMOUNT()
RETURNS VARCHAR(16777216)
LANGUAGE SQL
EXECUTE AS OWNER
AS '
BEGIN
    -- Update order_header discount based on promotion
    UPDATE ORDER_BASE.ORDER_HEADER oh
    SET DISCOUNT = 
    (CASE
        WHEN  oh.COUPON_CODE = ''Discount''
            -- AND oh.TOTAL_AMOUNT < 1000 
             AND p.CUSTOMER_CATEGORY IN (''Gold'', ''Silver'', ''Bronze'') 
             AND c.CUSTOMER_ID = oh.CUSTOMER_ID 
             -- AND p.CUSTOMER_CATEGORY = c.CATEGORY 
             AND oh.COUPON_CODE = ''Discount''
             AND p.PROMOTION_TYPE = oh.COUPON_CODE
                THEN p.PROMOTION_VALUE * oh.TOTAL_AMOUNT
        WHEN oh.COUPON_CODE IN (''Coupon_x'', ''Coupon_y'', ''Coupon_z'') 
             AND oh.CUSTOMER_ID = c.CUSTOMER_ID 
               AND p.CUSTOMER_CATEGORY IN (''Regular'')
                -- AND oh.TOTAL_AMOUNT < 1000
                THEN oh.TOTAL_AMOUNT - (oh.TOTAL_AMOUNT * p.PROMOTION_VALUE)
        
        ELSE 0
        END)
    
    from ORDER_BASE.CUSTOMER c 
    JOIN ORDER_BASE.PROMOTION p ON p.CUSTOMER_CATEGORY = c.CATEGORY
    WHERE oh.CUSTOMER_ID = c.CUSTOMER_ID ;

    UPDATE ORDER_BASE.CUSTOMER c
    SET LOYALTY_POINTS = p.PROMOTION_VALUE + LOYALTY_POINTS
    FROM ORDER_BASE.PROMOTION p
    -- JOIN ORDER_BASE.ORDER_HEADER oh ON p.CUSTOMER_CATEGORY = c.CATEGORY
    WHERE c.CUSTOMER_ID IN (
    SELECT oh.CUSTOMER_ID
    FROM ORDER_BASE.ORDER_HEADER oh
    WHERE oh.TOTAL_AMOUNT > 1000
        AND p.CUSTOMER_CATEGORY IN (''Gold'', ''Silver'', ''Bronze'') 
        AND oh.COUPON_CODE = ''Loyalty''
        AND p.PROMOTION_TYPE = oh.COUPON_CODE
);


    CALL update_order_amounts();

    RETURN ''Total amounts updated successfully'';
END;
';

