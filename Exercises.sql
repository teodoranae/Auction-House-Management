--6
CREATE OR REPLACE PROCEDURE PERFORMANTA IS
    TYPE TABLOU_INDEXAT IS TABLE OF LICITATIE.NUME%TYPE INDEX BY PLS_INTEGER;--tipurile de colectii utilizate in subprogram
    TYPE TABLOU_IMBRICAT IS TABLE OF NUMBER;
    TYPE VARRAY_PROD IS VARRAY(1000) OF NUMBER;
    
    TYPE DETALII_CATEGORIE IS RECORD (                  --alte tipuri de date, care ajuta la stocarea rezultatelor intoarse de cursorul pentru categorie
        denumire VARCHAR2(100),
        total_produse_per_categorie NUMBER,
        procent_categorie NUMBER  
    );
    TYPE INFO_CATEGORIE IS TABLE OF DETALII_CATEGORIE;
    
    CURSOR cursor_categorie(p_id_licitatie NUMBER) IS
        SELECT CATEGORIE.DENUMIRE_CATEGORIE, 
           COUNT(PRODUS.ID_PRODUS) AS TOTAL_PRODUSE,
           ROUND(SUM(CASE WHEN UPPER(PRODUS.STARE) = 'ADJUDECAT' THEN 1 ELSE 0 END) * 100.0 / COUNT(PRODUS.ID_PRODUS), 2) AS PC_CATEGORIE
        FROM LICITATIE_PRODUS
        JOIN PRODUS ON LICITATIE_PRODUS.ID_PRODUS = PRODUS.ID_PRODUS
        JOIN CATEGORIE ON PRODUS.ID_CATEGORIE = CATEGORIE.ID_CATEGORIE
        WHERE LICITATIE_PRODUS.ID_LICITATIE = p_id_licitatie
        GROUP BY CATEGORIE.ID_CATEGORIE, CATEGORIE.DENUMIRE_CATEGORIE;

    Nume_licitatii TABLOU_INDEXAT;                                          --colectiile utilizate
    Numar_produse_adjudecate VARRAY_PROD := VARRAY_PROD();
    Numar_produse_neadjudecate VARRAY_PROD := VARRAY_PROD();
    Procent_adjudecare TABLOU_IMBRICAT := TABLOU_IMBRICAT();
    Suma_totala TABLOU_IMBRICAT := TABLOU_IMBRICAT();
    info_suplimentar INFO_CATEGORIE;
    i NUMBER :=0;                                                           --indicele curent
    ct NUMBER := 0;                                                         --contorul care verifica daca echipa a organizat licitatii
    
BEGIN
        FOR echipa IN (SELECT ID_ECHIPA FROM ECHIPA_ORGANIZARE) LOOP        --pentru fiecare echipa
                                                                            --se afiseaza date despre performantele acesteia
        DBMS_OUTPUT.PUT_LINE('Performanta echipei cu ID-ul ' || echipa.ID_ECHIPA ||' :' );
        ct:=0;                                                              --numarul de licitatii organizate
        FOR LIC IN (                                                        --pentru fiecare licitatie
                    SELECT LICITATIE.ID_LICITATIE, LICITATIE.NUME AS DENUMIRE_LICITATIE,            --sunt necesare numele
                    SUM(CASE WHEN UPPER(PRODUS.STARE) = 'ADJUDECAT' THEN 1 ELSE 0 END) AS ADJUDECATE,   --numarul de produse adjudecate
                    SUM(CASE WHEN UPPER(PRODUS.STARE) = 'DISPONIBIL' THEN 1 ELSE 0 END) AS NEADJUDECATE,    --numarul de produse neadjudecate
                    ROUND(SUM(CASE WHEN UPPER(PRODUS.STARE) = 'ADJUDECAT' THEN 1 ELSE 0 END) * 100.0 /COUNT(DISTINCT PRODUS.ID_PRODUS), 2) AS PC_ADJUDECARE, --procentul; intr-o licitatie va fi minim un produs, deci nu este valabil scenariul cu impartirea la 0 
                    SUM(OFERTE_CASTIGATOARE.SUMA_PROPUSA) AS SUM_TOTALA                    --suma totala obtinuta in urma licitatiei
                    FROM LICITATIE
                    JOIN LICITATIE_PRODUS ON LICITATIE.ID_LICITATIE = LICITATIE_PRODUS.ID_LICITATIE
                    JOIN PRODUS ON LICITATIE_PRODUS.ID_PRODUS = PRODUS.ID_PRODUS
                    LEFT JOIN (                                                     --se filtreaza din OFERTA doar ofertele castigatoare
                                SELECT ID_PRODUS, MAX(SUMA_PROPUSA) AS SUMA_PROPUSA --prin left join, se includ toate randurile din tabelul PRODUS,
                                FROM OFERTA                                         --adica atat cele care se afla in OFERTE_CASTIGATOARE, cat si cele care nu se afla acolo, dar se afla in PRODUS
                                WHERE UPPER(ADJUDECARE) = 'DA'                      --astfel, este asigurata pastrarea tuturor produselor, indiferent daca 
                                GROUP BY ID_PRODUS                                  --au fost adjudecate sau nu
                                ) 
                                OFERTE_CASTIGATOARE ON PRODUS.ID_PRODUS = OFERTE_CASTIGATOARE.ID_PRODUS
                    WHERE LICITATIE.ID_ECHIPA = echipa.ID_ECHIPA
                    GROUP BY LICITATIE.ID_LICITATIE, LICITATIE.NUME) LOOP

                    i := i+1;
                    ct:= ct+1;
                    
                    Nume_licitatii(i) := LIC.DENUMIRE_LICITATIE;
                    
                    Numar_produse_adjudecate.EXTEND;                    --completarea colectiilor cu 
                    Numar_produse_adjudecate(i) := LIC.ADJUDECATE;      --elementele calculate
                    Numar_produse_neadjudecate.EXTEND;
                    Numar_produse_neadjudecate(i) := LIC.NEADJUDECATE;
                    Procent_adjudecare.EXTEND;
                    Procent_adjudecare(i) := LIC.PC_ADJUDECARE;
                    Suma_totala.EXTEND;
                    Suma_totala(i) := LIC.SUM_TOTALA;
                    
                    
                    DBMS_OUTPUT.PUT_LINE('Numele licitatiei: ' || Nume_licitatii(i));       --afisarea mesajelor aferente
                    DBMS_OUTPUT.PUT_LINE('Numarul produselor adjudecate: ' ||  Numar_produse_adjudecate(i));
                    DBMS_OUTPUT.PUT_LINE('Numarul produselor neadjudecate: ' ||  Numar_produse_neadjudecate(i));
                    DBMS_OUTPUT.PUT_LINE('Procentul de adjudecare: ' ||  Procent_adjudecare(i) || '%');
                    DBMS_OUTPUT.PUT_LINE('Suma totala acumulata: ' || Suma_totala(i));
                    
                    OPEN cursor_categorie(lic.ID_LICITATIE);                    --detaliile suplimentare pe categorie
                    FETCH cursor_categorie BULK COLLECT INTO info_suplimentar;
                    
                    FOR j IN 1..info_suplimentar.COUNT LOOP                     --numarul total de produse din categoria respectiva, prezente in licitatie
                            DBMS_OUTPUT.PUT_LINE('  Categoria: ' || info_suplimentar(j).denumire);      --si procentul de adjudecare al produselor din categorie
                            DBMS_OUTPUT.PUT_LINE('    Total produse in categorie: ' || info_suplimentar(j).total_produse_per_categorie);
                            DBMS_OUTPUT.PUT_LINE('    Procent adjudecare in categorie: ' || info_suplimentar(j).procent_categorie || '%');
                    END LOOP;
                    CLOSE cursor_categorie;
            
                    DBMS_OUTPUT.PUT_LINE('Sfarsitul detaliilor despre ' || lic.DENUMIRE_LICITATIE);
            
                    DBMS_OUTPUT.NEW_LINE;
                    
                    END LOOP;
                    
                     IF ct = 0 THEN             --echipa nu a organizat licitatii
                        DBMS_OUTPUT.PUT_LINE('Echipa ' || echipa.ID_ECHIPA || ' nu a organizat licitatii.');
                    END IF;
                END LOOP;
EXCEPTION   --in cazul exceptiilor neprevazute
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Eroare: ' || SQLERRM);
    
END;
/

BEGIN
    PERFORMANTA;        --apelul procedurii
END;
/


--7
CREATE OR REPLACE PROCEDURE CATEGORIE_INFORMATII_DETALIATE IS
    CURSOR Cursor_categorie IS                                          --primul cursor, neparametrizat
        SELECT ID_CATEGORIE, DENUMIRE_CATEGORIE
        FROM CATEGORIE;
    CURSOR Info_prod (p_categ CATEGORIE.ID_CATEGORIE%TYPE) IS           --al doilea cursor, parametrizat, dependent de primul
        SELECT MAX(OFERTA.SUMA_PROPUSA), CLIENT.NUME, CLIENT.PRENUME    --este nevoie de maximul sumelor propuse pentru un produs
        FROM PRODUS                                                     --din categoria data ca parametru
        JOIN OFERTA ON PRODUS.ID_PRODUS=OFERTA.ID_PRODUS                --suma care este, de altfel, si cea de la adjudecarea produsului;
        JOIN CLIENT ON OFERTA.ID_CLIENT=CLIENT.ID_CLIENT                --este necesar si numele complet al clientului care a castigat produsul
        WHERE PRODUS.ID_CATEGORIE=p_categ
        GROUP BY CLIENT.NUME, CLIENT.PRENUME
        HAVING MAX(OFERTA.SUMA_PROPUSA) = (                             --dorim numai oferta castigatoare cu pretul maxim, 
            SELECT MAX(OFERTA.SUMA_PROPUSA)                             --motiv pentru care filtram randurile in clauza HAVING
            FROM PRODUS
            JOIN OFERTA ON PRODUS.ID_PRODUS = OFERTA.ID_PRODUS          --astfel, se pastreaza doar maximul pentru fiecare categorie
            WHERE PRODUS.ID_CATEGORIE = p_categ
        );
    
    oferta_max NUMBER;                                                  --variabilele utilizate
    nume_client CLIENT.NUME%TYPE;                                       --pentru a incarca rezultatele cursoarelor
    prenume_client CLIENT.PRENUME%TYPE;
    id_categ CATEGORIE.ID_CATEGORIE%TYPE;
    denumire_categ CATEGORIE.DENUMIRE_CATEGORIE%TYPE;
    gasit NUMBER :=0;                                                   --cazul in care nu exista oferte castigatoare pentru categoria data
    
BEGIN
    OPEN Cursor_categorie;                                              --primul cursor parcurge toate categoriile
    LOOP
        FETCH Cursor_categorie INTO id_categ, denumire_categ;
        EXIT WHEN Cursor_categorie%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pentru categoria ' || denumire_categ || ':');
        
        OPEN Info_prod(id_categ);                                       --al doilea are drept parametru id-ul categoriei, rezultat din primul cursor
        LOOP
            FETCH Info_prod INTO oferta_max, nume_client, prenume_client;   --rezultatele cursorului parametrizat
            EXIT WHEN Info_prod%NOTFOUND;
            gasit :=1;                          --inseamna ca respectiva categorie are minim o oferta castigatoare
            DBMS_OUTPUT.PUT_LINE('Pretul maxim obtinut este de ' || oferta_max);        --mesajele aferente
            DBMS_OUTPUT.PUT_LINE('Numele clientului care a efectuat oferta este ' || prenume_client || ' ' || nume_client);
            DBMS_OUTPUT.NEW_LINE;
        END LOOP;
        IF gasit=0 THEN                         --cazul in care nu exista nicio oferta castigatoare pentru produsele din categoria data
            DBMS_OUTPUT.PUT_LINE('Nu exista oferte castigatoare pentru produsele din aceasta categorie');
            DBMS_OUTPUT.NEW_LINE;
        END IF;
        gasit :=0;
        CLOSE Info_prod;
        
    END LOOP;
    CLOSE Cursor_categorie;
END;
/

BEGIN
    CATEGORIE_INFORMATII_DETALIATE;             --apelul procedurii
END;


--8
CREATE OR REPLACE TYPE DETALII_OFERTE AS TABLE OF VARCHAR2(500);   --tablou imbricat
/
CREATE OR REPLACE FUNCTION DETALII_OFERTE_FIECARE_MANAGER (p_id_manager ECHIPA_ORGANIZARE.ID_MANAGER%TYPE) 
RETURN DETALII_OFERTE IS                            --vrem detaliile cerute legate de toate ofertele,
    rezultat DETALII_OFERTE := DETALII_OFERTE();
    licitatii NUMBER;                               --indiferent daca sunt castigatoare sau nu
    exista NUMBER;
    NU_A_ORGANIZAT_LICITATII EXCEPTION;
    
BEGIN
    SELECT COUNT(*)INTO exista                  
    FROM ECHIPA_ORGANIZARE
    WHERE ECHIPA_ORGANIZARE.ID_MANAGER = p_id_manager;
    
    IF exista = 0 THEN                          --cazul in care subprogramul este apelat pentru un manager care nu exista in tabel
        RAISE NO_DATA_FOUND;
    END IF;
    
    IF exista > 1 THEN                          --cazul in care subprogramul este apelat pentru un manager care a coordonat mai mult de o echipa
        RAISE TOO_MANY_ROWS;
    END IF;
        
    SELECT COUNT(*) INTO licitatii              --cazul in care subprogramul este apelat pentru un manager care a coordonat o singura echipa
    FROM LICITATIE                              --dar care nu a organizat nicio licitatie
    JOIN ECHIPA_ORGANIZARE ON LICITATIE.ID_ECHIPA=ECHIPA_ORGANIZARE.ID_ECHIPA
    WHERE ECHIPA_ORGANIZARE.ID_MANAGER=p_id_manager;
    
    IF licitatii = 0 THEN
        RAISE NU_A_ORGANIZAT_LICITATII;
    END IF;
    
    FOR o IN (                                                          --cazul in care nu are loc nicio exceptie
        SELECT CLIENT.NUME || ' ' || CLIENT.PRENUME AS NUME_COMPLET,
        LICITATIE.NUME AS NUME_LICITATIE,                               --iar tabloul imbricat poate fi populat cu datele necesare
        OFERTA.ADJUDECARE
        
        FROM OFERTA 
        JOIN LICITATIE ON OFERTA.ID_LICITATIE = LICITATIE.ID_LICITATIE
        JOIN ECHIPA_ORGANIZARE ON LICITATIE.ID_ECHIPA = ECHIPA_ORGANIZARE.ID_ECHIPA
        JOIN CLIENT ON OFERTA.ID_CLIENT = CLIENT.ID_CLIENT
        JOIN PRODUS ON OFERTA.ID_PRODUS = PRODUS.ID_PRODUS
        WHERE ECHIPA_ORGANIZARE.ID_MANAGER = p_id_manager
    ) LOOP
        rezultat.EXTEND;                                                --adaugarea elementelor
        rezultat(rezultat.LAST) := o.nume_complet || ' | ' || o.nume_licitatie || ' | ' || o.adjudecare;
    END LOOP;
    
    RETURN rezultat;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Managerul cu ID-ul ' || p_id_manager || ' nu exista!');
        RAISE_APPLICATION_ERROR(-20001, 'Managerul cu ID-ul ' || p_id_manager || ' nu exista!');
           
    WHEN NU_A_ORGANIZAT_LICITATII THEN
        DBMS_OUTPUT.PUT_LINE('Managerul cu ID-ul ' || p_id_manager || ' nu a coordonat nicio echipa care a organizat licitatii!');
        RAISE_APPLICATION_ERROR(-20001, 'Managerul cu ID-ul ' || p_id_manager || ' nu a coordonat nicio echipa care a organizat licitatii!');
        
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Managerul cu ID-ul ' || p_id_manager || ' a coordonat mai multe echipe!');
        RAISE_APPLICATION_ERROR(-20003, 'Managerul cu ID-ul ' || p_id_manager || ' a coordonat mai multe echipe!');
    WHEN OTHERS THEN  
        DBMS_OUTPUT.PUT_LINE('Alta eroare!');
        RAISE_APPLICATION_ERROR(-20004, 'Alta eroare!');

END; 
/
DECLARE
    oferte DETALII_OFERTE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Afisarea detaliilor legate de echipa coordonata de fiecare manager:');

    FOR echipa IN (SELECT ID_MANAGER FROM ECHIPA_ORGANIZARE GROUP BY ID_MANAGER) LOOP
        BEGIN
            oferte := DETALII_OFERTE_FIECARE_MANAGER(echipa.ID_MANAGER);  
            DBMS_OUTPUT.PUT_LINE('Detalii despre ofertele din licitatiile coordonate de managerul cu ID-ul ' || echipa.ID_MANAGER || ':');

            FOR I IN 1..oferte.COUNT LOOP
                BEGIN
                    DBMS_OUTPUT.PUT_LINE(oferte(I));
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('A fost intampinata o eroare la afisarea unei oferte!');
                END;
            END LOOP;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('A fost intampinata o eroare in cazul echipei precedente!');
        END;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    oferte := DETALII_OFERTE_FIECARE_MANAGER(8);         --cazul in care managerul nu exista; executia se va opri, iar mesajul din instructiunea urmatoare nu va fi afisat,
                                                          --intrucat exceptia nu este gestionata in cadrul unui subbloc
                                                          --intr-adevar, exista un angajat cu acest ID, dar nu este manager
    DBMS_OUTPUT.PUT_LINE('Echipa coordonata de managerul cu ID-ul 8 a ogranizat licitatii');
    

END;
/

--9
CREATE OR REPLACE PROCEDURE DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE(p_nume_client CLIENT.NUME%TYPE, p_prenume_client CLIENT.PRENUME%TYPE) IS
    v_id_client CLIENT.ID_CLIENT%TYPE;
    CURSOR cursor_licitatie IS
        SELECT LICITATIE.NUME AS NUME_LICITATIE, COUNT(OFERTA.ID_PRODUS) AS NUMAR_ACHIZITII, SUM(OFERTA.SUMA_PROPUSA) AS SUMA_TOTALA_ACHITATA, MANAGERI.PRENUME AS MANAGER_PRENUME, MANAGERI.NUME AS MANAGER_NUME, ECHIPA_ORGANIZARE.NUMAR_MEMBRI AS NUMAR_ANGAJATI
        FROM OFERTA
        JOIN LICITATIE ON OFERTA.ID_LICITATIE=LICITATIE.ID_LICITATIE                --pentru fiecare licitatie la care a participat clientul
        JOIN ECHIPA_ORGANIZARE ON LICITATIE.ID_ECHIPA=ECHIPA_ORGANIZARE.ID_ECHIPA
        JOIN MANAGERI ON ECHIPA_ORGANIZARE.ID_MANAGER=MANAGERI.ID_MANAGER
        JOIN CLIENT ON OFERTA.ID_CLIENT=CLIENT.ID_CLIENT                            --se extrag informatiile solicitate
        WHERE UPPER(CLIENT.NUME)=UPPER(p_nume_client)
        AND UPPER(CLIENT.PRENUME)=UPPER(p_prenume_client)
        AND UPPER(OFERTA.ADJUDECARE)='DA'
        GROUP BY LICITATIE.NUME, MANAGERI.PRENUME, MANAGERI.NUME, ECHIPA_ORGANIZARE.NUMAR_MEMBRI;
    v_licitatie cursor_licitatie%ROWTYPE;
    NU_EXISTA_CLIENTUL EXCEPTION;
    NU_A_LICITAT EXCEPTION;
    exista_oferte_castigatoare NUMBER :=0;
    a_licitat NUMBER :=0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Client: ' || p_prenume_client || ' ' || p_nume_client || ':');
    SELECT COUNT(*)                                 --exceptiile 
    INTO v_id_client
    FROM CLIENT
    WHERE UPPER(CLIENT.NUME)=UPPER(p_nume_client)
    AND UPPER(CLIENT.PRENUME)=UPPER(p_prenume_client);
    
    IF v_id_client = 0 THEN                         --clientul nu exista
        RAISE NU_EXISTA_CLIENTUL;
    END IF;
    
    IF v_id_client > 1 THEN                         --exista mai multi clienti cu numele dat
        RAISE TOO_MANY_ROWS;
    END IF;
    
    SELECT COUNT(*)
    INTO a_licitat
    FROM CLIENT
    JOIN OFERTA ON CLIENT.ID_CLIENT=OFERTA.ID_CLIENT
    WHERE UPPER(CLIENT.NUME)=UPPER(p_nume_client)
    AND UPPER(CLIENT.PRENUME)=UPPER(p_prenume_client);
    
    IF a_licitat = 0 THEN                           --clientul nu a licitat
        RAISE NU_A_LICITAT;
    END IF;
    
    
    OPEN cursor_licitatie;
    LOOP
        FETCH cursor_licitatie INTO v_licitatie; 
        EXIT WHEN cursor_licitatie%NOTFOUND;
        
        exista_oferte_castigatoare:=1;              --cursorul a procesat cel putin un rand
        
        
        DBMS_OUTPUT.PUT_LINE('Licitatie: ' || v_licitatie.NUME_LICITATIE);      --mesajele aferente
        DBMS_OUTPUT.PUT_LINE('Numarul total de achizitii efectuate de client: ' || v_licitatie.NUMAR_ACHIZITII);
        DBMS_OUTPUT.PUT_LINE('Suma totala achitata de client pana in momentul actual: ' || v_licitatie.SUMA_TOTALA_ACHITATA);
        DBMS_OUTPUT.PUT_LINE('Numele complet al managerului echipei de organizare a licitatiei: ' || v_licitatie.MANAGER_PRENUME || ' ' || v_licitatie.MANAGER_NUME);
        DBMS_OUTPUT.PUT_LINE('Numarul angajatilor din echipa de organizare: ' || v_licitatie.NUMAR_ANGAJATI);
        DBMS_OUTPUT.NEW_LINE;
        END LOOP;
        
    CLOSE cursor_licitatie; 
    IF exista_oferte_castigatoare = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
    WHEN NU_EXISTA_CLIENTUL THEN        --cazul in care nu exista niciun client cu numele dat
        DBMS_OUTPUT.PUT_LINE('Nu exista niciun client cu acest nume de familie!');
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista niciun client cu acest nume de familie!');
    WHEN TOO_MANY_ROWS THEN             --mai multi clienti cu acelasi nume
        DBMS_OUTPUT.PUT_LINE('Exista mai multi clienti cu acest nume!');
        RAISE_APPLICATION_ERROR(-20002, 'Exista mai multi clienti cu acest nume!');
    WHEN NO_DATA_FOUND THEN             --pentru cursor
        DBMS_OUTPUT.PUT_LINE('Clientul a licitat, dar nicio oferta castigatoare nu ii apartine!');
        RAISE_APPLICATION_ERROR(-20003, 'Clientul a licitat, dar nicio oferta castigatoare nu ii apartine!');
    WHEN NU_A_LICITAT THEN              --exista clienti care nu au licitat
        DBMS_OUTPUT.PUT_LINE('Clientul nu a licitat!');
        RAISE_APPLICATION_ERROR(-20004, 'Clientul nu a licitat!');
    WHEN OTHERS THEN                    --alte exceptii
        DBMS_OUTPUT.PUT_LINE('Alta eroare!');                   
        RAISE_APPLICATION_ERROR(-20005, 'Alta eroare!');
              
END;
/

--apeluri pentru toate cazurile, fiecare intr-un bloc separat

BEGIN
    DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE('Popescu', 'Andrei-Ioan');     --exista un singur client cu numele dat care a efectuat cel putin o achizitie

END;
/
BEGIN                                   --nu exista clientul
    DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE('Popa', 'Andreea');

END;
/
BEGIN
    DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE('Stanescu', 'Matei');    --exista mai multi clienti cu numele de familie dat

END;
/
BEGIN
    DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE('Dobrinescu', 'Mihai-Cosmin');  --clientul exista, este unic, dar nu a licitat

END;
/
BEGIN
    DETALII_SUPLIMENTARE_OFERTE_CASTIGATOARE('Mihailescu', 'Georgiana');    --clientul exista, este unic, a licitat, dar nu a castigat niciun produs

END;
/

--10

CREATE OR REPLACE TRIGGER PEMISIUNI 

BEFORE INSERT OR UPDATE OR DELETE ON ANGAJATI

BEGIN
    IF UPPER(SYS.LOGIN_USER) <> 'UTILIZATOR' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Utilizatorul nu poate modifica tabelul ANGAJATI');
    ELSIF UPPER(TO_CHAR(SYSDATE, 'HH24')) NOT BETWEEN 8 AND 10 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nu aveti permisiunea sa modificati tabelul la aceasta ora!');
    END IF;
END;


     
CREATE OR REPLACE TRIGGER MARIRE_SALARIU
BEFORE INSERT OR UPDATE OR DELETE ON ANGAJATI
FOR EACH ROW
BEGIN
    IF :NEW.SALARIU > 0.3*:OLD.SALARIU+:OLD.SALARIU THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nu se poate efectua marirea de salariu! Procentul de marire depaseste limita impusa!');
    ELSIF :NEW.SALARIU<:OLD.SALARIU THEN
        RAISE_APPLICATION_ERROR(-20004, 'Nu se pot efectua scaderi de salariu!');
    END IF;
END;   

UPDATE ANGAJATI         --vechiul salariu: 8000
SET SALARIU = 8100
WHERE ID_ANGAJAT=1;

UPDATE ANGAJATI         --vechiul salariu: 3400
SET SALARIU = 7000
WHERE ID_ANGAJAT=11;

UPDATE ANGAJATI         --incercare de modificare in afara programului de lucru
SET SALARIU = 8600
WHERE ID_ANGAJAT=2;

UPDATE ANGAJATI         --scaderea
SET SALARIU = 8000
WHERE ID_ANGAJAT=1;

--11
-- cu incercare de lucru pe tabela mutating
CREATE TABLE ACTUALIZARE_ACHIZITIE(
    ID_CLIENT NUMBER,
    ID_PRODUS NUMBER,
    ID_LICITATIE NUMBER,
    MESAJ VARCHAR2(200));
CREATE OR REPLACE TRIGGER DECLANSATOR_STERGERE_ACHIZITIE
AFTER DELETE ON ACHIZITIE
FOR EACH ROW
DECLARE
    nr_oferta NUMBER;
BEGIN
    SELECT COUNT(*) INTO nr_oferta
    FROM ACHIZITIE
    WHERE ID_CLIENT = :OLD.ID_CLIENT;
    INSERT INTO ACTUALIZARE_ACHIZITIE VALUES (:OLD.ID_CLIENT, :OLD.ID_PRODUS, :OLD.ID_LICITATIE, 'Stergere efectuata');
    
END;

SELECT * FROM OFERTA;
SELECT * FROM ACHIZITIE;
SELECT * FROM PLATA;

DELETE FROM ACHIZITIE
WHERE ID_CLIENT = 1;

-- cu tratarea exceptiei si folosirea unui subprogram pentru stergere in cascada
CREATE OR REPLACE PROCEDURE STERGERE_CASCADA (
    p_id_client IN NUMBER,
    p_id_produs IN NUMBER,
    p_id_licitatie IN NUMBER
    ) IS
BEGIN
    DELETE FROM OFERTA                  --stergere in cascada
    WHERE ID_CLIENT = p_id_client
    AND ID_PRODUS = p_id_produs
    AND ID_LICITATIE = p_id_licitatie;  --pentru oferta
    
    DELETE FROM PLATA
    WHERE ID_CLIENT = p_id_client       --respectiv plata
    AND ID_PRODUS = p_id_produs
    AND ID_LICITATIE = p_id_licitatie;
END;
/

CREATE OR REPLACE TRIGGER DECLANSATOR_STERGERE_ACHIZITIE
AFTER DELETE ON ACHIZITIE
FOR EACH ROW
DECLARE
    nr_oferta NUMBER;
    tabel_mutating EXCEPTION;
    PRAGMA EXCEPTION_INIT(tabel_mutating, -4091);
BEGIN
    SELECT COUNT(*) INTO nr_oferta
    FROM ACHIZITIE
    WHERE ID_CLIENT = :OLD.ID_CLIENT;
    INSERT INTO ACTUALIZARE_ACHIZITIE VALUES (:OLD.ID_CLIENT, :OLD.ID_PRODUS, :OLD.ID_LICITATIE, 'Stergere efectuata');
EXCEPTION
    WHEN tabel_mutating THEN
        STERGERE_CASCADA(:OLD.ID_CLIENT, :OLD.ID_PRODUS, :OLD.ID_LICITATIE);
        INSERT INTO ACTUALIZARE_ACHIZITIE VALUES (:OLD.ID_CLIENT, :OLD.ID_PRODUS, :OLD.ID_LICITATIE, 'Stergere efectuata');

END;

SELECT * FROM OFERTA;
SELECT * FROM ACHIZITIE;
SELECT * FROM PLATA;

DELETE FROM ACHIZITIE
WHERE ID_CLIENT = 1;

SELECT * FROM ACTUALIZARE_ACHIZITIE;

--12
CREATE TABLE TABEL_INFO
(
    DATA_ACTUALIZARE DATE,                      --tabelul ce va contine date referitoare la comenzile
    INSTRUCTIUNE VARCHAR2(30),                  --LDD efectuate asupra unei vizualizari
    UTILIZATOR VARCHAR2(50),
    MESAJ VARCHAR2(100)
)

CREATE OR REPLACE TRIGGER INFO_TRIG 
AFTER CREATE OR DROP ON SCHEMA             --tabelul este populat cu datele solicitate
DECLARE
    mesaj VARCHAR2(100);                            --doar in cazul vizualizarilor
BEGIN
    IF UPPER(SYS.DICTIONARY_OBJ_TYPE) = 'VIEW' THEN     --altfel, comenzile se executa, fara introducerea datelor
        mesaj := 'Utilizatorul a efectuat o comanda ' || SYS.SYSEVENT || ' pentru vizualizarea ' || SYS.DICTIONARY_OBJ_NAME; 
        INSERT INTO TABEL_INFO VALUES(SYSDATE, SYS.SYSEVENT, SYS.LOGIN_USER, mesaj);
    END IF;                                             --in tabelul TABEL_INFO
END;

SELECT * FROM TABEL_INFO;               --inainte de orice instructiune

CREATE OR REPLACE VIEW VIZ_ANG AS SELECT NUME, PRENUME FROM ANGAJATI;   --se creeaza vizualizarea

SELECT * FROM TABEL_INFO;
DROP VIEW VIZ_ANG;                      --se sterge vizualizarea
SELECT * FROM TABEL_INFO;
CREATE TABLE TABEL_NOU AS SELECT * FROM ANGAJATI;       --se creeaza un tabel
SELECT * FROM TABEL_INFO;               --operatia nu are niciun efect asupra INFO_TABEL
CREATE SEQUENCE SECV;                   --se creeaza o secventa
SELECT * FROM TABEL_INFO;               --din nou, operatia nu determina modificarea tabelului INFO_TABEL

--13
ALTER TABLE CLIENT
ADD STATUT VARCHAR2(20) DEFAULT 'STANDARD';
select * from client;

CREATE OR REPLACE PACKAGE PACHET_ARTMARK AS
    TYPE DETALII_CLIENT IS RECORD (                 --cele 3 tipuri de date definite in pachet
        id_client NUMBER,
        id_licitatie NUMBER,
        nr_oferte NUMBER
        );
    TYPE LISTA_DETALII IS TABLE OF DETALII_CLIENT;
    TYPE LISTA_CLIENTI IS TABLE OF NUMBER;
        
    FARA_OFERTE EXCEPTION;     --in cazul in care nu a fost lansata nicio oferta in licitatie, o exceptie

        
    FUNCTION TOP_CLIENT(p_id_licitatie NUMBER) RETURN LISTA_CLIENTI;    --id-urile membrilor
    FUNCTION PRODUSE_CLIENT(p_id_client NUMBER) RETURN LISTA_DETALII;   --pentru un membru, detaliile despre numarul de oferte in fiecare licitatie
    FUNCTION TOP_CLIENTI_LICITATII RETURN LISTA_DETALII;                --mai multe detalii despre ofertele lansate de membri
    FUNCTION ESTE_MEMBRU(p_id_client NUMBER) RETURN BOOLEAN;            --ca sa nu se faca mai multe marcari decat este necesar,
                                                                        --un membru se marcheaza doar o data
                                                                        
    PROCEDURE MARCARE_MEMBRI;                                           --marcheaza membrii in tabelul de clienti
    PROCEDURE APLICA_REDUCERE(p_id_client NUMBER);                      --aplica reducerea, cu limitarile impuse de cerinta 
    PROCEDURE LOG_ACTIUNI(mesaj VARCHAR2);                              --evidenta actiunilor
    PROCEDURE PROCESARE_COMPLETA;                                       --procedura care executa fluxul complet de actiuni
END PACHET_ARTMARK;
/


CREATE OR REPLACE PACKAGE BODY PACHET_ARTMARK AS

    FUNCTION ESTE_MEMBRU(p_id_client NUMBER) RETURN BOOLEAN IS         --procedura care verifica daca un client
        v_statut VARCHAR2(20);
    BEGIN 
        SELECT STATUT                                                  --eligibil pentru statutul de membru a fost deja marcat
        INTO v_statut
        FROM CLIENT                                                     --in tabel, deci nu este necesara nicio modificare
        WHERE ID_CLIENT = p_id_client;
        
        RETURN (UPPER(v_statut) = 'MEMBRU');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END ESTE_MEMBRU;
    
    FUNCTION TOP_CLIENT(p_id_licitatie NUMBER) RETURN LISTA_CLIENTI     --id-urile membrilor
    IS
        v_lista LISTA_CLIENTI := LISTA_CLIENTI();
        maxi NUMBER := 0;
    BEGIN
        SELECT MAX(ct)                          -- se numara ofertele lansate de fiecare client in
        INTO maxi                               --cadrul unei licitatii
        FROM (
                SELECT COUNT(*) ct
                FROM OFERTA
                WHERE ID_LICITATIE = p_id_licitatie
                GROUP BY ID_CLIENT
                );                              --si se pastreaza maximul
                
        IF maxi = 0 THEN
            RAISE FARA_OFERTE;
        END IF;
        
        SELECT ID_CLIENT BULK COLLECT INTO v_lista      --se pun in lista toate id-urile clientilor care au lansat
        FROM (
                SELECT ID_CLIENT, COUNT(*) ct           --un numar maxim de oferte in acea licitatie
                FROM OFERTA
                WHERE ID_LICITATIE = p_id_licitatie
                GROUP BY ID_CLIENT
                )
                WHERE ct = maxi;
        RETURN v_lista;                                 --se returneaza lista
    END TOP_CLIENT;
    
    FUNCTION PRODUSE_CLIENT(p_id_client NUMBER)         --detalii despre ofertele unui membru
        RETURN LISTA_DETALII
    IS
        v_detalii LISTA_DETALII := LISTA_DETALII();
        v_client DETALII_CLIENT;
    BEGIN
        FOR rec IN (                                            --se tine cont de client,
            SELECT ID_CLIENT, ID_LICITATIE, COUNT(*) as ct      --de licitatie
            FROM OFERTA
            WHERE ID_CLIENT = p_id_client                       --si de ofertele plasate de acesta
            GROUP BY ID_CLIENT, ID_LICITATIE
            ) LOOP                                              --in cadrul oricarei licitatii
                v_client.id_client := rec.ID_CLIENT;
                v_client.id_licitatie := rec.ID_LICITATIE;
                v_client.nr_oferte := rec.ct;
                                                                --se adauga detaliile in colectie
                v_detalii.EXTEND;
                v_detalii(v_detalii.LAST) := v_client;
            END LOOP;
        RETURN v_detalii;                                       --se returneaza detaliile
    END PRODUSE_CLIENT;
    
    FUNCTION TOP_CLIENTI_LICITATII RETURN LISTA_DETALII IS
            CURSOR cursor_licitatie IS
                SELECT ID_LICITATIE FROM LICITATIE;
            v_lista LISTA_CLIENTI;
            v_detalii LISTA_DETALII := LISTA_DETALII();
            v_client DETALII_CLIENT;
            v_nr_oferte NUMBER;
        BEGIN                                       --pentru fiecare licitatie, se 
            FOR lic IN cursor_licitatie LOOP
                v_lista := TOP_CLIENT(lic.ID_LICITATIE);        --pastreaza membrii
                FOR i IN 1..v_lista.COUNT LOOP
                    SELECT COUNT(*)                 --si numarul lor de oferte
                    INTO v_nr_oferte
                    FROM OFERTA
                    WHERE ID_CLIENT = v_lista(i) AND ID_LICITATIE = lic.ID_LICITATIE;
                    
                    v_client.id_client := v_lista(i);           --se adauga toate aceste detalii
                    v_client.id_licitatie := lic.ID_LICITATIE;
                    v_client.nr_oferte := v_nr_oferte;          --in colectie
                    
                    v_detalii.EXTEND;
                    v_detalii(v_detalii.LAST) := v_client;
                END LOOP;
            END LOOP;
            RETURN v_detalii;                                   --si se returneaza
        END TOP_CLIENTI_LICITATII;
        
        PROCEDURE MARCARE_MEMBRI IS                     --marcheza membrii
            v_lista LISTA_DETALII;
        BEGIN 
            v_lista := TOP_CLIENTI_LICITATII;
            FOR i IN 1..v_lista.COUNT LOOP              --prin actualizarea coloanei STATUT
                IF NOT ESTE_MEMBRU(v_lista(i).id_client) THEN
                    UPDATE CLIENT                       --din tabelul CLIENT,
                    SET STATUT = 'MEMBRU'               --insa numai daca acesta nu a mai fost marcat deja
                    WHERE ID_CLIENT = v_lista(i).id_client;
                    LOG_ACTIUNI('Clientul ' || v_lista(i).id_client || ' este membru');

                END IF;
            END LOOP;
        EXCEPTION
            WHEN FARA_OFERTE THEN
                LOG_ACTIUNI('Nicio oferta in vreo licitatie!');
        END MARCARE_MEMBRI;
        
        PROCEDURE APLICA_REDUCERE(p_id_client NUMBER) IS
            CURSOR cursor_produs IS                     --bineinteles, de data aceasta este nevoie
                SELECT PRODUS.ID_PRODUS, OFERTA.SUMA_PROPUSA
                FROM PRODUS                             --de o verificare suplimentara, 
                JOIN OFERTA ON OFERTA.ID_PRODUS = PRODUS.ID_PRODUS
                WHERE UPPER(OFERTA.ADJUDECARE) = 'DA'   --anume daca oferta este una castigatoare
                AND OFERTA.ID_CLIENT = p_id_client
                ORDER BY OFERTA.SUMA_PROPUSA ASC;       --astfel, sunt selectate produsele adjudecate in urma
                                                        --ofertei cu suma cea mai mare
            v_prod_id NUMBER;
            v_pret NUMBER;
            v_suma_plati NUMBER;
            v_id_plata NUMBER;
            v_suma NUMBER;
            v_reducere NUMBER;

            CURSOR cursor_max_plata(v_prod NUMBER, v_client NUMBER) IS      --in cazul in care plata a fost efectuata
                SELECT ID_PLATA, SUMA
                FROM PLATA                                     --in mai mult de o etapa, 
                WHERE ID_CLIENT = v_client
                AND ID_PRODUS = v_prod                      --o pastram pe cea cu suma mai mare
                ORDER BY SUMA DESC;

        BEGIN
            OPEN cursor_produs;
            FETCH cursor_produs INTO v_prod_id, v_pret;
    
            IF cursor_produs%NOTFOUND THEN          --poate ca un membru nu a castigat,
                CLOSE cursor_produs;                --de fapt, niciun produs
                LOG_ACTIUNI('Niciun produs adjudecat pentru clientul ' || p_id_client);
                RETURN;
            END IF;
            CLOSE cursor_produs;

            v_reducere := v_pret * 0.1;

            SELECT SUM(SUMA) INTO v_suma_plati          --vrem ca reducerea sa se aplice o singura data
            FROM PLATA                                 
            WHERE ID_CLIENT = p_id_client               
            AND ID_PRODUS = v_prod_id;

            IF v_suma_plati = v_pret - v_reducere THEN      --prin urmare, verificam acest lucru
                LOG_ACTIUNI('Reducerea a fost deja aplicata pentru clientul '||p_id_client||' la produsul '|| v_prod_id);
                RETURN;
            END IF;

            OPEN cursor_max_plata(v_prod_id, p_id_client);
            FETCH cursor_max_plata INTO v_id_plata, v_suma;
            CLOSE cursor_max_plata;

            UPDATE PLATA                     --asupra platii celei mai mari, in caz de 
            SET SUMA = v_suma - v_reducere   --achitare in mai multe etape
            WHERE ID_PLATA = v_id_plata;

            LOG_ACTIUNI('Reducerea aplicata pentru clientul '||p_id_client||' la produsul '||v_prod_id);
        END APLICA_REDUCERE;

        
        PROCEDURE LOG_ACTIUNI(mesaj VARCHAR2) IS        --evidenta mesajelor pe parcursul procesarii
        BEGIN
            INSERT INTO LOG_ACTIUNI VALUES (mesaj);
        END LOG_ACTIUNI;
        
        PROCEDURE PROCESARE_COMPLETA IS
            CURSOR cursor_licitatii IS      
                SELECT ID_LICITATIE FROM LICITATIE;
            detalii_top LISTA_CLIENTI;
        BEGIN
            FOR lic IN cursor_licitatii LOOP            --pentru fiecare licitatie
                detalii_top := TOP_CLIENT(lic.ID_LICITATIE);    --sunt extrase id-urile persoanelor
                FOR i IN 1..detalii_top.COUNT LOOP      --eligibile pentru statutul de MEMBRU
                    IF detalii_top(i) IS NOT NULL THEN
                        APLICA_REDUCERE(detalii_top(i)); --se aplica reducerea membrilor,
                    END IF;                         --folosind conventiile precizate
                END LOOP;
                MARCARE_MEMBRI; --se actualizeaza statutul
            END LOOP;
        END PROCESARE_COMPLETA;

END PACHET_ARTMARK;
/


CREATE TABLE LOG_ACTIUNI (MESAJ VARCHAR2(200));
            
            
BEGIN
    PACHET_ARTMARK.PROCESARE_COMPLETA;
    DBMS_OUTPUT.PUT_LINE('Procesare completa a membrilor si reducerilor efectuata');
END;
/
SELECT * FROM LOG_ACTIUNI;


DECLARE
    v_detalii PACHET_ARTMARK.LISTA_DETALII;  --daca vrem sa vedem si detaliile despre ofertele
BEGIN
    v_detalii := PACHET_ARTMARK.PRODUSE_CLIENT(3);  --lansate de un client, spre exemplu clientul 3
    FOR i IN 1..v_detalii.COUNT LOOP                --putem folosi functia definita in pachet cu acest scop
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_detalii(i).id_client || ', Licitatie: ' || v_detalii(i).id_licitatie || ', Numarul ofertelor lansate: ' || v_detalii(i).nr_oferte);
    END LOOP;
END;
/

    
