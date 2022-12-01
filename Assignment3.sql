CREATE OR REPLACE FUNCTION FUNC_PERMISSIONS_OKAY RETURN VARCHAR2 IS
    V_PERMISSION_OKAY VARCHAR2(1);
BEGIN
    SELECT
        'Y' INTO V_PERMISSION_OKAY
    FROM
        USER_TAB_PRIVS
    WHERE
        PRIVILEGE = 'EXECUTE'
        AND TABLE_NAME = 'UTL_FILE';
    IF V_PERMISSION_OKAY IS NULL THEN
        V_PERMISSION_OKAY := 'N';
    END IF;
    RETURN V_PERMISSION_OKAY;
END;
/


CREATE OR REPLACE TRIGGER TRG_PAYROLL_LOAD AFTER
    INSERT ON PAYROLL_LOAD FOR EACH ROW
BEGIN
    INSERT INTO NEW_TRANSACTIONS (
        TRANSACTION_NO,
        TRANSACTION_DATE,
        DESCRIPTION,
        ACCOUNT_NO,
        TRANSACTION_TYPE,
        TRANSACTION_AMOUNT
    ) VALUES (
        WKIS_SEQ.NEXTVAL,
        :NEW.PAYROLL_DATE,
        'For '
            || :NEW.EMPLOYEE_ID,
        2050,
        'C',
        :NEW.AMOUNT
    );
    INSERT INTO NEW_TRANSACTIONS (
        TRANSACTION_NO,
        TRANSACTION_DATE,
        DESCRIPTION,
        ACCOUNT_NO,
        TRANSACTION_TYPE,
        TRANSACTION_AMOUNT
    ) VALUES (
        WKIS_SEQ.NEXTVAL,
        :NEW.PAYROLL_DATE,
        'For '
            || :NEW.EMPLOYEE_ID,
        4045,
        'D',
        :NEW.AMOUNT
    );
    UPDATE PAYROLL_LOAD
    SET STATUS = 'G'
    WHERE EMPLOYEE_ID = :NEW.EMPLOYEE_ID
        AND PAYROLL_DATE = :NEW.PAYROLL_DATE;
EXCEPTION
    WHEN OTHERS THEN
        UPDATE PAYROLL_LOAD
        SET STATUS = 'B'
        WHERE EMPLOYEE_ID = :NEW.EMPLOYEE_ID
            AND PAYROLL_DATE = :NEW.PAYROLL_DATE;
END;
/


CREATE OR REPLACE PROCEDURE PROC_MONTH_END IS
    CURSOR CUR_ACCOUNTS IS
        SELECT
            ACCOUNT_NO,
            ACCOUNT_NAME,
            ACCOUNT_TYPE_CODE,
            ACCOUNT_BALANCE
        FROM
            ACCOUNT
        WHERE
            ACCOUNT_TYPE_CODE IN ('RE', 'EX');
    V_ACCOUNT_NO NUMBER;
    V_ACCOUNT_TYPE VARCHAR2(2);
    V_BALANCE NUMBER;
BEGIN   
    FOR CUR_ACCOUNTS_RECORD IN CUR_ACCOUNTS LOOP
        V_ACCOUNT_NO := CUR_ACCOUNTS_RECORD.ACCOUNT_NO;
        V_ACCOUNT_TYPE := CUR_ACCOUNTS_RECORD.ACCOUNT_TYPE_CODE;
        V_BALANCE := CUR_ACCOUNTS_RECORD.ACCOUNT_BALANCE;
        IF V_ACCOUNT_TYPE = 'RE' THEN
            INSERT INTO NEW_TRANSACTIONS (
                TRANSACTION_NO,
                TRANSACTION_DATE,
                DESCRIPTION,
                ACCOUNT_NO,
                TRANSACTION_TYPE,
                TRANSACTION_AMOUNT
            ) VALUES (
                WKIS_SEQ.NEXTVAL,
                SYSDATE,
                'For '
                    || V_ACCOUNT_NO,
                V_ACCOUNT_NO,
                'D',
                V_BALANCE
            );
            INSERT INTO NEW_TRANSACTIONS (
                TRANSACTION_NO,
                TRANSACTION_DATE,
                DESCRIPTION,
                ACCOUNT_NO,
                TRANSACTION_TYPE,
                TRANSACTION_AMOUNT
            ) VALUES (
                WKIS_SEQ.NEXTVAL,
                SYSDATE,
                'For '
                    || V_ACCOUNT_NO,
                5555,
                'C',
                V_BALANCE
            );
        ELSE
            INSERT INTO NEW_TRANSACTIONS (
                TRANSACTION_NO,
                TRANSACTION_DATE,
                DESCRIPTION,
                ACCOUNT_NO,
                TRANSACTION_TYPE,
                TRANSACTION_AMOUNT
            ) VALUES (
                WKIS_SEQ.NEXTVAL,
                SYSDATE,
                'For '
                    || V_ACCOUNT_NO,
                V_ACCOUNT_NO,
                'C',
                V_BALANCE
            );
            INSERT INTO NEW_TRANSACTIONS (
                TRANSACTION_NO,
                TRANSACTION_DATE,
                DESCRIPTION,
                ACCOUNT_NO,
                TRANSACTION_TYPE,
                TRANSACTION_AMOUNT
            ) VALUES (
                WKIS_SEQ.NEXTVAL,
                SYSDATE,
                'For '
                    || V_ACCOUNT_NO,
                5555,
                'D',
                V_BALANCE
            );
        END IF;
    END LOOP;
END;
/
