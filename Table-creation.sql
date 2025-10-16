--4
--1 - client
CREATE SEQUENCE ID_CLIENT_SEQ START WITH 1;
CREATE TABLE CLIENT(
    ID_CLIENT NUMBER PRIMARY KEY NOT NULL,
    NUME VARCHAR2(50),
    PRENUME VARCHAR2(50),
    EMAIL VARCHAR(100)
);
--2 - categorie
CREATE SEQUENCE ID_CATEGORIE_SEQ START WITH 1;
CREATE TABLE CATEGORIE
(
    ID_CATEGORIE NUMBER PRIMARY KEY NOT NULL,
    DENUMIRE_CATEGORIE VARCHAR2(50)
);
--3 - departamente
CREATE SEQUENCE ID_DEPARTAMENT_SEQ START WITH 1;
CREATE TABLE DEPARTAMENTE (
    ID_DEPARTAMENT NUMBER PRIMARY KEY NOT NULL,
    NUME_DEPARTAMENT VARCHAR2(50),
    DETALII VARCHAR2(70)
);
--4 - manageri
CREATE SEQUENCE ID_MANAGER_SEQ START WITH 1;
CREATE TABLE MANAGERI (
    ID_MANAGER NUMBER PRIMARY KEY NOT NULL,
    ID_DEPARTAMENT NUMBER,
    NUME VARCHAR2(20),
    PRENUME VARCHAR2(20),
    EMAIL VARCHAR2(100),
    TELEFON CHAR(10),
    SALARIU NUMBER(5),
    DATA_PRELUARE_FUNCTIE DATE,
    CONSTRAINT manager_dep_fk FOREIGN KEY (ID_DEPARTAMENT) REFERENCES DEPARTAMENTE(ID_DEPARTAMENT)
);
--5 - angajati
CREATE SEQUENCE ID_ANGAJAT_SEQ START WITH 1;
CREATE TABLE ANGAJATI (
    ID_ANGAJAT NUMBER PRIMARY KEY NOT NULL,
    ID_MANAGER NUMBER,
    ID_DEPARTAMENT NUMBER,
    NUME VARCHAR2(20),
    PRENUME VARCHAR2(20),
    EMAIL VARCHAR2(100),
    TELEFON CHAR(10),
    SALARIU NUMBER(5),
    CONSTRAINT angajat_manager_fk FOREIGN KEY (ID_MANAGER) REFERENCES MANAGERI(ID_MANAGER),
    CONSTRAINT angajat_dept_fk FOREIGN KEY (ID_DEPARTAMENT) REFERENCES DEPARTAMENTE(ID_DEPARTAMENT)
);

--6 - echipa_organizare
CREATE SEQUENCE ID_ECHIPA_SEQ START WITH 1;
CREATE TABLE ECHIPA_ORGANIZARE (
    ID_ECHIPA NUMBER PRIMARY KEY NOT NULL,
    ID_MANAGER NUMBER,
    NUMAR_MEMBRI NUMBER(3),
    CONSTRAINT echipa_manager_fk FOREIGN KEY (id_manager) REFERENCES MANAGERI(id_manager)
);

--7 - angajati organizare
CREATE TABLE ANGAJATI_ORGANIZARE
        	(
            ID_ECHIPA NUMBER NOT NULL,
             ID_ANGAJAT NUMBER NOT NULL,
            CONSTRAINT ang_org_pk PRIMARY KEY( ID_ECHIPA,ID_ANGAJAT),
            CONSTRAINT ang_org_fk FOREIGN KEY (ID_ANGAJAT) REFERENCES ANGAJATI(ID_ANGAJAT),
            CONSTRAINT ang_echipa_fk FOREIGN KEY (ID_ECHIPA) REFERENCES ECHIPA_ORGANIZARE(ID_ECHIPA)
         );

--8 - licitatie
CREATE SEQUENCE ID_LICITATIE_SEQ START WITH 1;
CREATE TABLE LICITATIE (
    ID_LICITATIE NUMBER PRIMARY KEY NOT NULL,
    ID_ECHIPA NUMBER,
    NUME VARCHAR2(255),
    DATA DATE,
    ORA_INCEPUT VARCHAR2(5),
    ORA_FINAL VARCHAR2(5),
    CONSTRAINT licitatie_echipa_fk FOREIGN KEY (ID_ECHIPA) REFERENCES ECHIPA_ORGANIZARE(ID_ECHIPA)
);

 --9 - produs
CREATE SEQUENCE ID_PRODUS_SEQ START WITH 1;
CREATE TABLE PRODUS
(
    ID_PRODUS NUMBER PRIMARY KEY NOT NULL,
    ID_CATEGORIE NUMBER,
    DESCRIERE VARCHAR2(200),
    ESTIMARE NUMBER,
    PRET_DE_PORNIRE NUMBER,
    CONSTRAINT produs_categ_fk FOREIGN KEY (ID_CATEGORIE) REFERENCES CATEGORIE(ID_CATEGORIE)
);

--10 - licitatie_produs
CREATE TABLE LICITATIE_PRODUS(
    ID_LICITATIE NUMBER NOT NULL,
    ID_PRODUS NUMBER NOT NULL,
    CONSTRAINT licitatie_prod_pk PRIMARY KEY(ID_LICITATIE, ID_PRODUS),
    CONSTRAINT licitatie_fk FOREIGN KEY (ID_LICITATIE) REFERENCES LICITATIE(ID_LICITATIE),
    CONSTRAINT produs_fk FOREIGN KEY (ID_PRODUS) REFERENCES PRODUS(ID_PRODUS)
    );
--11 - oferta
CREATE TABLE OFERTA (
    ID_CLIENT NUMBER NOT NULL,
    ID_PRODUS NUMBER NOT NULL,
    ID_LICITATIE NUMBER NOT NULL,
    SUMA_PROPUSA NUMBER,
    ADJUDECARE VARCHAR2(2),
    CONSTRAINT oferta_pk PRIMARY KEY (ID_CLIENT, ID_PRODUS, ID_LICITATIE),
    CONSTRAINT oferta_client_fk FOREIGN KEY (ID_CLIENT) REFERENCES CLIENT(ID_CLIENT),
    CONSTRAINT oferta_produs_fk FOREIGN KEY (ID_PRODUS) REFERENCES PRODUS(ID_PRODUS),
    CONSTRAINT oferta_licitatie_fk FOREIGN KEY (ID_LICITATIE) REFERENCES LICITATIE(ID_LICITATIE)
);
--12 - achizitie

CREATE TABLE ACHIZITIE
        (
        ID_CLIENT NUMBER NOT NULL,
        ID_PRODUS NUMBER NOT NULL,
	ID_LICITATIE NUMBER NOT NULL,
        DETALII VARCHAR2(255),
        CONSTRAINT achizitie_pk PRIMARY KEY (ID_CLIENT, ID_PRODUS, ID_LICITATIE),
	CONSTRAINT achizitie_oferta_fk FOREIGN KEY (ID_CLIENT, ID_PRODUS, ID_LICITATIE) REFERENCES OFERTA(ID_CLIENT, ID_PRODUS, ID_LICITATIE)
        );
--13 - plata
CREATE SEQUENCE ID_PLATA_SEQ START WITH 1;
CREATE TABLE PLATA (
    ID_PLATA NUMBER PRIMARY KEY NOT NULL,
    ID_CLIENT NUMBER NOT NULL,
    ID_PRODUS NUMBER NOT NULL,
    ID_LICITATIE NUMBER NOT NULL,
    SUMA NUMBER,
    DETALII_PLATA VARCHAR2(255),
    CONSTRAINT plata_achizitie_fk FOREIGN KEY (ID_CLIENT, ID_PRODUS, ID_LICITATIE) REFERENCES ACHIZITIE(ID_CLIENT, ID_PRODUS, ID_LICITATIE)
);

--5
--1 - client
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Popescu', 'Andrei-Ioan', 'p.andrei@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Mirescu', 'Gabriela', 'gabriella.m@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Marasescu', 'Petru-Mihai', 'pm.marasescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Stanescu', 'Matei', 'msmatei@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Petrescu', 'Paul', 'ppetrescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Ionescu', 'Iulia-Andreea', 'iulia_ionescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Radulescu', 'George-Mihai', 'georgemradulescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Cretulescu', 'Cosmin-Andrei', 'cosminandreicretulescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Antonescu', 'Mihai', 'mantonescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Barbulescu', 'Victor', 'victor.barbulescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Andreescu', 'Ilinca-Maria', 'ilincaandreescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Marinescu', 'Crina-Antonia', 'camarinescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Georgescu', 'Vlad-Alexandru', 'vlad_g_alex@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Alexandrescu', 'Miruna-Maria', 'mirunaalexandrescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Danescu', 'Daniela', 'd.daniela@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Dascalescu', 'Ioana-Camelia', 'ioanacameliadascalescu@yhoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Dobrinescu', 'Mihai-Cosmin', 'mihaic.dobrinescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Dumitrescu', 'Mariana', 'marianadumitrescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Mihailescu', 'Georgiana', 'gmihailescu@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Vasilescu', 'Rares', 'vasilescurares@yahoo.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Stoenescu', 'Ana-Maria', 'anamstoenescu@gmail.com');
INSERT INTO CLIENT
VALUES (ID_CLIENT_SEQ.nextval, 'Stanescu', 'Ioana', 'istanescu@gmail.com');
INSERT INTO CLIENT VALUES(ID_CLIENT_SEQ.NEXTVAL, 'Stanescu', 'Matei', 'mateistanescu98@gmail.com');

--2 - categorie
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Grafica');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Pictura contemporana');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Pictura interbelica');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Ceramica-Portelan');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Obiecte din argint');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Bijuterii');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Orologerie');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Arta religioasa');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Sculpturi');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Obiecte din sticla');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Mobilier');
INSERT INTO CATEGORIE
VALUES (ID_CATEGORIE_SEQ.nextval, 'Diverse');

--3 - departamente
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Resurse Umane', 'Gestionare personal si recrutare');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'IT', 'Administrare sisteme si suport tehnic');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Vanzari', 'Strategii de vanzari si relatie cu clientii');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Marketing', 'Promovare si strategii de marketing');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Financiar', 'Management financiar si contabilitate');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Achizitii', 'Gestionarea achizitiilor si furnizorilor');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Productie', 'Coordonarea proceselor de productie');
INSERT INTO DEPARTAMENTE  VALUES
(ID_DEPARTAMENT_SEQ.nextval, 'Logistica', 'Gestionarea transporturilor si depozitarii');

--4 - manageri
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 2, 'Popescu', 'Ion', 'ion.popescu@artmark.com', '0712345678', 5000, TO_DATE('2018-01-15', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 1, 'Ionescu', 'Maria', 'maria.ionescu@artmark.com', '0712345679', 5500, TO_DATE('2020-06-01', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 6, 'Georgescu', 'Andrei', 'andrei.georgescu@artmark.com', '0712345680', 6000, TO_DATE('2021-09-23', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 3, 'Popa', 'Elena', 'elena.popa@artmark.com', '0712345681', 5200, TO_DATE('2020-03-12', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 4, 'Dumitru', 'Mihai', 'mihai.dumitru@artmark.com', '0712345682', 5300, TO_DATE('2021-11-30', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 5, 'Stoicescu', 'Alexandra', 'alexandra.stoicescu@artmark.com', '0712345683', 5800, TO_DATE('2019-07-15', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 8, 'Radu', 'Vasile', 'vasile.radu@artmark.com', '0712345684', 5400, TO_DATE('2022-02-20', 'YYYY-MM-DD'));
INSERT INTO MANAGERI VALUES
(ID_MANAGER_SEQ.nextval, 7, 'Tudor', 'Ioana', 'ioana.tudor@artmark.com', '0712345685', 5600, TO_DATE('2023-04-10', 'YYYY-MM-DD'));

--5 - angajati
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 2, 'Popescu', 'Ion', 'ion.popescu@artmark.com', '0712345678', 8000);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 1, 'Ionescu', 'Maria', 'maria.ionescu@artmark.com', '0712345679', 8500);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 6, 'Georgescu', 'Andrei', 'andrei.georgescu@artmark.com', '0712345680', 7500);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 3, 'Popa', 'Elena', 'elena.popa@artmark.com', '0712345681', 9000);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 4, 'Dumitru', 'Mihai', 'mihai.dumitru@artmark.com', '0712345682', 8300);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 5, 'Stoicescu', 'Alexandra', 'alexandra.stoicescu@artmark.com', '0712345683', 8500);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 8, 'Radu', 'Vasile', 'vasile.radu@artmark.com', '0712345684', 8400);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, NULL, 7, 'Tudor', 'Ioana', 'ioana.tudor@artmark.com', '0712345685', 7700);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 1, 2, 'Dima', 'Ion', 'ion.dima@artmark.com', '0712345688', 3100);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 2, 1, 'Moldovan', 'Elena', 'elena.moldovan@artmark.com', '0712345689', 3300);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 3, 6, 'Vasilescu', 'Maria', 'maria.vasilescu@artmark.com', '0712345690', 3400);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 4, 3, 'Grigorescu', 'Daniel', 'daniel.grigorescu@artmark.com', '0712345691', 3500);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 5, 4, 'Anghel', 'Ana', 'ana.anghel@artmark.com', '0712345692', 3600);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 6, 5, 'Iordache', 'Gabriel', 'gabriel.iordache@artmark.com', '0712345693', 3700);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 7, 8, 'Diaconescu', 'Mihai', 'mihai.diaconescu@artmark.com', '0712345694', 3800);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 8, 7, 'Enescu', 'Catalina', 'catalina.enescu@artmark.com', '0712345695', 3900);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 1, 2, 'Barbu', 'Ionut', 'ionut.barbu@artmark.com', '0712345696', 4000);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 2, 1, 'Nistor', 'Gabriela', 'gabriela.nistor@artmark.com', '0712345697', 4100);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 3, 6, 'Marin', 'Alexandru', 'alexandru.marin@artmark.com', '0712345698', 3000);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 4, 3, 'Popescu', 'Cristina', 'cristina.popescu@artmark.com', '0712345699', 3200);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 5, 4, 'Marin', 'Mihai', 'mihai.marin@artmark.com', '0712345700', 3300);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 6, 5, 'Gherghe', 'Ana', 'ana.gherghe@artmark.com', '0712345701', 3400);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 7, 8, 'Ionescu', 'Vlad', 'vlad.ionescu@artmark.com', '0712345702', 3500);
INSERT INTO ANGAJATI VALUES
(ID_ANGAJAT_SEQ.nextval, 8, 7, 'Stan', 'Andreea', 'andreea.stan@artmark.com', '0712345703', 3600);

--6 - echipa_organizare
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 1, 3);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 3, 6);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 5, 4);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 7, 9);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 2, 3);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 1, 4);
INSERT INTO ECHIPA_ORGANIZARE VALUES
(ID_ECHIPA_SEQ.nextval, 4, 2);

--7 - angajati_organizare
INSERT INTO ANGAJATI_ORGANIZARE values(1, 9);
INSERT INTO ANGAJATI_ORGANIZARE values(1, 13);
INSERT INTO ANGAJATI_ORGANIZARE values(2, 13);
INSERT INTO ANGAJATI_ORGANIZARE values(2, 17);
INSERT INTO ANGAJATI_ORGANIZARE values(2, 23);
INSERT INTO ANGAJATI_ORGANIZARE values(2, 15);
INSERT INTO ANGAJATI_ORGANIZARE values(2, 21);
INSERT INTO ANGAJATI_ORGANIZARE values(3, 15);
INSERT INTO ANGAJATI_ORGANIZARE values(3, 24);
INSERT INTO ANGAJATI_ORGANIZARE values(3, 9);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 14);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 18);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 9);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 17);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 20);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 24);
INSERT INTO ANGAJATI_ORGANIZARE values(4, 21);
INSERT INTO ANGAJATI_ORGANIZARE values(5, 17);
INSERT INTO ANGAJATI_ORGANIZARE values(5, 19);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(1, 1);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(6, 1);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(2, 3);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(3, 5);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(4, 7);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(5, 2);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(6, 16);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(6, 13);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(6, 22);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(7, 13);
INSERT INTO ANGAJATI_ORGANIZARE VALUES(7, 4);

--8 - licitatie
INSERT INTO LICITATIE  VALUES
(ID_LICITATIE_SEQ.nextval, 1, 'Licitatia de iarna', TO_DATE('2024-12-17', 'YYYY-MM-DD'),'19:00','22:00');
INSERT INTO LICITATIE VALUES
(ID_LICITATIE_SEQ.nextval, 2,  'Licitatia de mobilier', TO_DATE('2024-06-02', 'YYYY-MM-DD'), '10:00', '13:00');
INSERT INTO LICITATIE  VALUES
(ID_LICITATIE_SEQ.nextval, 3,  'Licitatia de primavara', TO_DATE('2024-03-03', 'YYYY-MM-DD'), '19:00', '21:00');
INSERT INTO LICITATIE VALUES
(ID_LICITATIE_SEQ.nextval, 5, 'Licitatia de bijuterii', TO_DATE('2024-04-04', 'YYYY-MM-DD'), '12:00', '15:00');
INSERT INTO LICITATIE  VALUES
(ID_LICITATIE_SEQ.nextval, 4, 'Licitația de decoratiuni interioare', TO_DATE('2024-06-05', 'YYYY-MM-DD'), '13:00', '16:00');
INSERT INTO LICITATIE VALUES
(ID_LICITATIE_SEQ.nextval, 2,  'Licitatia de obiecte din argint', TO_DATE('2024-06-06', 'YYYY-MM-DD'), '14:00', '17:00');
INSERT INTO LICITATIE VALUES
(ID_LICITATIE_SEQ.nextval, 1, 'Licitatia de arta religioasa', TO_DATE('2024-06-07', 'YYYY-MM-DD'), '15:00', '18:00');

--9 - produs
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 1, 'Stefan Luchian (1868-1916)-"Portretul pictorului Constantin Artachino", carbune, 45x35 cm', 1700, 900);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 1, 'Gheorghe Petrascu (1872-1949)-"Peisaj din Turtucaia", tus, 24.5x32.5 cm', 2100, 1600);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 2, 'Vasile Grigore (1935-2012)-"Cai la malul marii", ulei pe carton, 69.5x20.5 cm', 1200, 900);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 2, 'Viorel Marginean (1933-2022)-"Pasarea Paradis", ulei pe panza, 65x454 cm', 1100, 900);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 3, 'Arthur Verona (1867-1946)-"Cu barca", ulei pe carton, 33x43 cm', 1400, 900);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 3, 'Adam Baltatu (1899-1979)-"Ceapa si lingura de lemn", ulei pe carton, 30x42 cm', 1100, 850);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval,  4, 'Sase farfurii pentru aperitive, portelan decorat, jum. sec. XX', 20);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 4,  'Vas ornamental, portelan pictat, stil Art Nouveau, H 21 cm, inc. sec. XX', 100);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 4, 'Serviciu ceai/cafea: sase cesti cu farfurii, sase farfurii pentru desert, platou rotund, portelan decorat cu cobalt, jum. sec. XX', 90);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 4, 'Lampa de plafon, cu petrol, ceramica, sticla colorata in masa, bronz, elemente Art Nouveau, H 73cm, inc. sec. XX', 200);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 5, 'Lupa cu maner, sticla optica si argint 800 marcat, L 14 cm, dia. 5.5 cm Franta 1945/1950', 70);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 5, 'Calimara cu capac, argint 925 marcat, dia. 11 cm, H 5 cm, 1905', 70);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 6,'Inel stil Art Deco, aur galben 18K marcat, circumferinta 49 mm, 6.40g, Franta 1940', 500);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 6,'Lant cu pandantiv steluta, aur galben 14K marcat, lant L 56.5 cm, pandantiv L 3 cm, 3.36 g, Italia, 1950', 180);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 6, 'Inel, aur galben 14K marcat, executie manuala, decor cu rubin de sinteza, 2.92, atelier romanesc, jum. sec XX', 150);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 7, 'Ceas de mana Vacheron Constantin, cu certificat de autenticitate dat de R.A.P.P.S in data de 30.03.1994, stare de functionare', 400);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 7, 'Ceas de buzunar Vacheron Constantin, carcasa si capac aur 18K marcat, in stare de functionare', 2000);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 8, '"Isus Hristos", tempera si foita de aur pe lemn, 65.5x41 cm, Tara Romaneasca, sec. XIX', 320);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 8, '"Maica Domnului indurerata si Sfanta Paraschiva", tempera pe glaja, 46x63 cm, Tara Fagarasului, sec. XIX', 450);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 9, 'Adrian Popovici (1943-2009)-"Ofranda", bronz, H 28 cm', 1300, 1000);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 10, '"Pisica si peste"-doua piese ornamentale, cristal inscriptionat, H 22.5/17 cm, a II-a jum. a sec. XX', 70);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 10, 'Fructiera rotunda, cristal colorat in masa, dia. 38 cm, a II-a jum. a sec. XX', 30);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 10, 'Set sase cupe pe picior, cristal fasetat, ambalaj original, H 16.5 cm, a II-a jum. a sec. XX', 30);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 11, 'Postament cilindric in stil Art Deco, prima jumatate a sec. XX', 250, 150);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 11,'Cuier transilvanean de perete in stil Art Nouveau, decorat cu oglinda, cca. 1910', 350, 200);
INSERT INTO PRODUS
VALUES (ID_PRODUS_SEQ.nextval, 11, 'Comoda tip Boulle in stil Napoleon III, ornata cu intarsii si decoratiuni din bronz, sfarsitul sec. XIX', 900 ,600);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 11, 'Jardiniera pe patru picioruse, alama decorata in relief, H 26 cm, Franta, perioada interbelica', 60);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 12, 'Doua fluiere, inscriptionate Sibiu 1904 Romania, lemn pirogravat', 40);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 12, 'Patru piese pentru servit ceai/cafea, metal placat cu argint, decorat in relief, perioada interbelica', 70);
INSERT INTO PRODUS(ID_PRODUS, ID_CATEGORIE, DESCRIERE, PRET_DE_PORNIRE)
VALUES (ID_PRODUS_SEQ.nextval, 12, 'Rama pentru tablou, lemn si stuc aurit, 36x47 cm (interior), perioada interbelica', 150);

--10 - licitatie_produs
INSERT INTO LICITATIE_PRODUS VALUES (1, 1);
INSERT INTO LICITATIE_PRODUS VALUES (1, 6);
INSERT INTO LICITATIE_PRODUS VALUES (5, 7);
INSERT INTO LICITATIE_PRODUS VALUES (5, 8);
INSERT INTO LICITATIE_PRODUS VALUES (5, 23);
INSERT INTO LICITATIE_PRODUS VALUES (2, 26);
INSERT INTO LICITATIE_PRODUS VALUES (2, 27);
INSERT INTO LICITATIE_PRODUS VALUES (6, 29);
INSERT INTO LICITATIE_PRODUS VALUES (4, 15);
INSERT INTO LICITATIE_PRODUS VALUES (4, 14);
INSERT INTO LICITATIE_PRODUS VALUES (4, 13);
INSERT INTO LICITATIE_PRODUS VALUES (3, 2);
INSERT INTO LICITATIE_PRODUS VALUES (3, 4);
INSERT INTO LICITATIE_PRODUS VALUES (7, 18);
INSERT INTO LICITATIE_PRODUS VALUES (7, 19);
INSERT INTO LICITATIE_PRODUS VALUES (6, 12);
INSERT INTO LICITATIE_PRODUS VALUES (1, 16);
INSERT INTO LICITATIE_PRODUS VALUES (2, 30);
INSERT INTO LICITATIE_PRODUS VALUES (1, 24);  
INSERT INTO LICITATIE_PRODUS VALUES (1, 3);  
INSERT INTO LICITATIE_PRODUS VALUES (1, 5);  
INSERT INTO LICITATIE_PRODUS VALUES (3, 21);
INSERT INTO LICITATIE_PRODUS VALUES (3, 10);
INSERT INTO LICITATIE_PRODUS VALUES (3, 9);
INSERT INTO LICITATIE_PRODUS VALUES (6, 11);

--11 - oferta
INSERT INTO OFERTA VALUES (3, 3, 1 , 1700, 'Nu');
INSERT INTO OFERTA VALUES (12, 3, 1 , 2500, 'Da');
INSERT INTO OFERTA VALUES (1, 23, 5, 100, 'Da' );
INSERT INTO OFERTA VALUES (5, 18, 7, 400, 'Da');
INSERT INTO OFERTA VALUES (3, 7, 5, 100, 'Da');
INSERT INTO OFERTA VALUES (10, 15, 4, 300, 'Nu');
INSERT INTO OFERTA VALUES (9, 15, 4, 500, 'Da');
INSERT INTO OFERTA VALUES (5, 2, 3, 2700, 'Nu');
INSERT INTO OFERTA VALUES (11, 2, 3, 3100, 'Da');
INSERT INTO OFERTA VALUES (2, 6, 1, 2100, 'Nu' );
INSERT INTO OFERTA VALUES (13, 6, 1, 2200, 'Da' );
INSERT INTO OFERTA VALUES (1, 19, 7, 600, 'Da');
INSERT INTO OFERTA VALUES (2, 12, 6, 150, 'Da' );
INSERT INTO OFERTA VALUES (16, 14, 4, 300, 'Da' );
INSERT INTO OFERTA VALUES (8, 27, 2, 80, 'Da');
INSERT INTO OFERTA VALUES (14, 30, 2, 300, 'Da');
INSERT INTO OFERTA VALUES (4, 8, 5, 300, 'Da');
INSERT INTO OFERTA VALUES (7, 5, 1, 2500, 'Da' );
INSERT INTO OFERTA VALUES (19, 5, 1, 2300, 'Nu' );
INSERT INTO OFERTA VALUES (10, 24, 1, 700, 'Da');
INSERT INTO OFERTA VALUES (6, 21, 3, 100, 'Da');
INSERT INTO OFERTA VALUES (15, 10, 3, 400, 'Da');
INSERT INTO OFERTA VALUES (20, 9, 3, 200, 'Da' );
INSERT INTO OFERTA VALUES (21, 11, 6, 200, 'Da');

--12 - achizitie
INSERT INTO ACHIZITIE VALUES (5, 18, 7, 'Achizitie de arta religioasa');
INSERT INTO ACHIZITIE VALUES (12, 3, 1, 'Achizitie de pictura contemporana');
INSERT INTO ACHIZITIE VALUES (8, 27, 2, 'Achizitie de decoratiuni');
INSERT INTO ACHIZITIE VALUES (3, 7, 5, 'Achizitie de obiecte din ceramica');
INSERT INTO ACHIZITIE VALUES (9, 15, 4, 'Achizitie de bijuterii');
INSERT INTO ACHIZITIE VALUES (11, 2, 3, 'Achizitie de grafica');
INSERT INTO ACHIZITIE VALUES (1, 19, 7, 'Achizitie de arta religioasa');
INSERT INTO ACHIZITIE VALUES (6, 21, 3, 'Achizitie de obiecte din sticla');
INSERT INTO ACHIZITIE VALUES (15, 10, 3, 'Achizitie de obiecte din ceramica');
INSERT INTO ACHIZITIE VALUES (14, 30, 2, 'Achizitie de obiecte diverse');
INSERT INTO ACHIZITIE VALUES (4, 8, 5, 'Achizitie de obiecte din portelan');
INSERT INTO ACHIZITIE VALUES (10, 24, 1, 'Achizitie de mobilier');
INSERT INTO ACHIZITIE VALUES (7, 5, 1, 'Achizitie de pictura interbelica');
INSERT INTO ACHIZITIE VALUES (2, 12, 6, 'Achizitie de obiecte din argint');
INSERT INTO ACHIZITIE VALUES (16, 14, 4, 'Achizitie bijuterii');
INSERT INTO ACHIZITIE VALUES (13, 6, 1,'Achizitie de pictura interbelica');
INSERT INTO ACHIZITIE VALUES (20, 9, 3,'Achizitie de obiecte din ceramica');
INSERT INTO ACHIZITIE VALUES (1, 23, 5,'Achizitie de obiecte din sticla');
INSERT INTO ACHIZITIE VALUES (21, 11, 6, 'Achizitie de obiecte din argint');

--13 - plata
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 5, 18, 7, 400, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 12, 3, 1, 1000, 'Plata partiala - card');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 12, 3, 1, 1500, 'Plata partiala - numerar, plata finalizata');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 8, 27, 2, 80, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 3, 7, 5, 100, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 9, 15, 4, 500, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 11, 2, 3, 1500, 'Plata partiala - numerar');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 11, 2, 3, 1600, 'Plata partiala - card, transfer final');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 1, 19, 7, 600, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 6, 21, 3, 100, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 15, 10, 3, 400, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 14, 30, 2, 300, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 4, 8, 5, 300 , 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 10, 24, 1, 700 , 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 7, 5, 1, 2000, 'Plata cu cardul - primul transfer');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 7, 5, 1, 500, 'Plata cu cardul - transfer final');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 2, 12, 6, 150, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 16, 14, 4, 300, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 13, 6, 1, 1000, 'Plata - primul transfer');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 13, 6, 1, 1200, 'Plata - transfer final');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 20, 9, 3, 200, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 1, 23, 5, 100, 'Plata integrala');
INSERT INTO PLATA VALUES (ID_PLATA_SEQ.nextval, 21, 11, 6, 200, 'Plata integrala');

ALTER TABLE PRODUS
ADD STARE VARCHAR2(20) DEFAULT 'Disponibil';

UPDATE PRODUS
SET STARE = 'Adjudecat'
WHERE ID_PRODUS IN (SELECT ID_PRODUS FROM ACHIZITIE);
UPDATE PRODUS
SET ESTIMARE = 0
WHERE ESTIMARE IS NULL;

