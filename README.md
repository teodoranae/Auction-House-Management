## Introducere 
Prezentul proiect ilustrează baza de date a unei aplicații utilizate pentru administrarea unei case de licitații, reținând date despre organizarea, desfășurarea și participarea la licitațiile din cadrul acesteia. Această bază de date facilitează gestionarea datelor despre evenimentele desfășurate în cadrul casei de licitații Artmark, dar și despre angajați și ierarhia lor.
<img width="975" height="651" alt="image" src="https://github.com/user-attachments/assets/79cc04e6-3a77-4f64-bf14-f8003d7b5245" />

## Cerința 6
Analizați performanțele fiecărei echipe de organizare: afișați numărul de produse adjudecate, numărul de produse neadjudecate, procentul de adjudecare, suma totală pentru fiecare licitație organizată de echipa respectivă. De asemenea, analizați fiecare categorie din fiecare licitație organizată de fiecare echipă din următoarele puncte de vedere: numărul total de produse din categoria respectivă prezente în licitație și procentul de adjudecare în categorie.

## Cerința 7 
Pentru fiecare categorie de produse, afișați prețul maxim obținut în urma adjudecărilor produselor din categoria respectivă, împreună cu numele clientului care a efectuat oferta câștigătoare. 

## Cerința 8
Afișați, pentru fiecare manager, următoarele detalii despre ofertele lansate de clienți în cadrul tuturor licitațiilor organizate de echipa coordonată de acesta: numele complet al clientului care a lansat-o, numele licitației și dacă oferta este câștigătoare sau nu. Știind că toți managerii fac parte din minim o echipă de organizare, tratați cazurile în care nu există managerul cu ID-ul dat ca parametru, cazul în care acesta face parte din mai mult de o echipă de organizare, cazul în care face parte dintr-o singură echipă de organizare, dar care nu a organizat licitații. 

## Cerința 9 
Pentru un client al cărui nume complet este dat, afișați detalii despre ofertele câștigătoare ale acestuia și despre licitațiile în cadrul cărora le-a efectuat: numele fiecărei licitații, numărul produselor achiziționate de client în cadrul acesteia, suma totală achitată de acesta în cadrul licitației, numele managerului echipei care s-a ocupat de organizarea licitației, numărul membrilor din echipa de organizare.

## Cerința 10 
Definiți un declanșator care să permită numai utilizatorului UTILIZATOR lucrul asupra tabelelor ANGAJATI. Programul de lucru este 8:00-10:00, în fiecare zi. În caz că dorește să mărească salariul unui angajat, acesta nu îl va putea mări cu mai mult de 30% (cerință ce presupune definirea unui alt declanșator, la nivel de linie). De asemenea, scăderile de salariu nu sunt permise.  

## Cerința 11
Definiți un declanșator care determină ștergerea unei achiziții. Modificați-l ulterior astfel încât, în loc de eroarea cauzată de tabelul mutating, acesta să efectueze ștergerea unei oferte, dar și a plăților aferente, dacă achiziția corespunzătoare acestora este eliminată din tabel. Creați tabelul ACTUALIZARE_ACHIZITII cu următoarele câmpuri: id_client, id_produs, id_licitatie, mesaj. Declanșatorul va introduce datele corespunzătoare în tabel pe măsură ce actualizările sunt efectuate.

## Cerința 12
Definiți un declanșator care, după fiecare instrucțiune LDD efectuată asupra unei vizualizări, introduce informații despre aceasta în tabelul TABEL_INFO. Coloanele tabelului sunt:

## Cerința 13 
Ne dorim ca experiența clienților să fie cât mai plăcută. Prin urmare, cu ajutorul statutului de MEMBRU, aceștia pot beneficia de diverse reduceri. Membrii sunt clienții care au lansat cele mai multe oferte în cadrul unei licitații, indiferent dacă acestea au rezultat în adjudecarea produsului sau nu. Cu ajutorul unui pachet, modificați tabelul CLIENT, pentru a reflecta și statutul (membru sau client standard), apoi aplicați o reducere de 10% la produsul cu prețul cel mai scăzut achiziționat de fiecare membru în cadrul unei licitații. Schimbările nu trebuie efectuate asupra tabelului OFERTA, întrucât clienții ofertează cu un preț, eventual mai mare decât prețul de pornire al produsului. Acestea vor fi, totuși, reflectate în tabelul de plăți, pentru a păstra evidența tranzacțiilor realizate. De asemenea, reducerea poate fi aplicată o singură dată, iar, în cazul în care achiziția respectivă s-a efectuat în mai multe etape, procentul se va scădea din plata cea mai mare.
