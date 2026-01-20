DO
$add_projects$
    BEGIN
        PERFORM add_project('Uruchomienie prostego emulatora MIPS w Python dla firmware ALI M3801 (Hello World)', 'Pietruszka1', 'Pokażę tutaj moje pierwsze starcie z budową emulatora dla mikroprocesora ALI M3801 w oparciu o gotowe moduły Unicorn i Capstone. Opracowany program będzie wczytywać zawartość pamięci Flash i wykonywać ją podobnie jak prawdziwy fizyczny CPU, choć nie obejdzie się bez przeróbek i poprawek, gdyż Unicorn/Capstone nie implementują pełnej logiki konkretnego SoC ani jego peryferiów. Dodatkowo całość będzie w stanie poprawnie obsłużyć wysyłanie danych przez UART, tzn. będzie emulować rejestr odpowiedzialny za nadawanie bajtów przez sprzętową magistralę szeregową. W ten sposób otrzymamy w konsoli te same komunikaty, które pokazywałoby uruchomienie programu na prawdziwym układzie ALI.

\nUżyte narzędzia\n
Ghidra to zaawansowane narzędzie do inżynierii wstecznej (SRE) rozwijane przez NSA. Umożliwia dekompilację kodu maszynowego MIPS do pseudo-kodu C, co znacznie ułatwia analizę i zrozumienie logiki firmware.
\nUnicorn  to lekki, wielplatformowy framework do emulacji CPU oparty na QEMU. W projekcie służy jako główny silnik do emulacji instrukcji MIPS32 w trybie Little Endian, choć w praktyce i tak duża część operacji (w tym dostęp do pamięci) jest obsługiwana osobno w moim kodzie.
\nCapstone to zaaawansowany silnik deasemblacji wspierający wiele architektur. Wykorzystywany jest tutaj do konwertowania kodu maszynowego na czytelne instrukcje asemblera, co jest niezbędna do ich śledzenia i debugowania. Pozwala użytkownikowi widzieć dokładnie, co w danej chwili wykonuje procesor.
\nProjekt wykonam w języku Pyhon.');
        PERFORM add_project('µCurrent', 'Staszeczek', 'The uCurrent™ is the only commercially available solution to the problem of burden voltage on a multimeter. See the article below to see why this little known problem can be a real big issue, even with your “precision” 0.05% Fluke multimeter. It also turns your multimeter into a powerful and precise nanoamp level measurement tool!
\n\n
\nThousands are in use all around the world, and it has quickly become the industry standard low cost tool for low power current measurement in modern low power microcontroller based digital electronics.
\n\n
\nThe µCurrent™ GOLD is the latest design with greatly improved specs over the original. Improvements have been made in basic accuracy, bandwidth (now you can measure fast changing “sleep” modes), current handling, and an added shorting mode to ensure uninterrupted power to your device under test while changing ranges. The µCurrent can rival 5 1/2 digit multimeters in accuracy, it is truly a precision instrument.');
        PERFORM add_project('Przewaga STM32 nad AVR', 'wrocławskiRok',
                            'The µCurrent™ GOLD is the latest design with greatly improved specs over the original. Improvements have been made in basic accuracy, bandwidth (now you can measure fast changing “sleep” modes), current handling, and an added shorting mode to ensure uninterrupted power to your device under test while changing ranges. The µCurrent can rival 5 1/2 digit multimeters in accuracy, it is truly a precision instrument.
\n\n
\nFor increased battery life and greater potential output voltage swing, 3 x AAA batteries in series can be used instead of the coin cell. No modifications are required, just wire in parallel with the existing coin cell holder. A 3 x AAA holder fits in the existing box.');
        PERFORM add_project('µSupply!', 'wrocławskiRok', 'The µSupply is a compact Arduino compatible battery powered laboratory power supply.
\nSpecifications:
\n0-20.48V
\n0-1A constant current limiting
\nLoad current display 40mA (10uA resolution), 80mA (20uA resolution), 160mA (40uA resolution), 320mA (80uA resolution), or 1A (1mA resolution)
\nOptional Ethernet Interface
\nArduino programming compatible (emulates an Arduino pro)
\nPowered from 2 x 18650 Lithium Ion cells.');
        PERFORM add_project('µRuler!', 'wrocławskiRok', 'A handy 7″ PCB ruler, don’t settle for an average 6 incher!
\nWith handy reference charts, and end stop so can be used as a depth gauge.
\nOriginally given away as EEVblog merchandise at the 2012 Electronex Show
\nManufactured by www.pcbzone.net in New Zealand.
\n
\nRev 1 files are HERE
\nRev 2 files are HERE');
        PERFORM add_project('Getting Started with Teensy!', 'wrocławskiRok', 'Teensy is a high-powered alternative to Arduino. It’s compact, adaptable, and offers fantastic value for money. Teensy is now available on circuito.io (!) so we thought it would be a nice idea to introduce you all to the wonderful world of Teensy, and explore how to get it up and running.
\n\n
\nA Little History
\nThis family of prototyping boards started in late 2008 with the Teensy 1.0, which offered 12Mbps native USB (as opposed to the slower serial standards found on the Arduino boards of the time). Teensy 2.0 arrived just a year later and introduced support for USB keyboards, mice and MIDI devices.
\n\n
\nThe third generation of Teensy boards got off the ground thanks to a successful Kickstarter campaign. While it wasn’t actually the first 32-bit Arduino-compatible prototyping board (that distinction belongs to Maple), it did help to get most of the popular Arduino libraries working on more capable hardware.
\n\n
\nIn 2014, Teensy versions 3.1 and 3.2 launched, offering four times as much RAM and a faster processor.
\n\n
\nIn 2016 the 3.5 and 3.6 Teensy boards were released after another crowdfunding effort, of the 3.5 and 3.6 Teensy boards. These are the most powerful boards produced by the company up to date.');
        PERFORM add_project('How to Make an Interactive Cat Laser Pointer!', 'wrocławskiRok', 'It’s been quite a while since our last project because we’ve been busy releasing circuito.io 3.0 (check it out!). When we finally sat down to think about what to make, we concluded that we’ve made a few projects for dogs, but none for cats, And that’s just wrong! From there, it didn’t take long until the cat laser pointer was underway. It’s a perfect mix of playfulness and laziness, just the way we like it.
\n\n
So what did we do?
\n\n
We made an interactive cat laser game thats controlled via mobile, and also has an automatic mode. We used a pan-tilt unit we found online (info and credit later on in this post), adjusted it to fit the laser diode, connected it to our phone with a Bluetooth module and started playing around with Pepper the cat, who turned out to be quite the Flamenco dancer.');
    end;
$add_projects$;

DO
$add_threads$
    BEGIN
        PERFORM add_thread('KiCad Automated Routing Tools', 'mikoWart', 'Would not it be great to have a "Route airwires" button in KiCad that just instantly routed all the tracks on your PCB for you? We are not yet at the point where such a tool is possible, except for the simplest of boards. PCB routing is complicated! (Ground and power planes, via placement, decoupling with low inductance, differential pairs, length matching, BGA fanout, wider power tracks, impedance matching, return currents, spacing for noise prevention, etc. - not to mention cleverly getting everything to connect in a limited space without violating DRC!) Plus, you want some control over how your board is routed - your experience is valuable and only you understand what the final product needs to be. But at the moment KiCad does almost nothing to help you route your board. This project is about developing the tools that will let you (or you+AI) route a KiCad PCB more quickly, while keeping the quality high.');
        PERFORM add_thread('Lifi Data Transfer System', 'Justice', 'LiFi technology utilizes led‟s for transmitting data. It is subsidiary of optical remote communication technology utilizing light from Led to convey rapid communication. Apparent light communication works by turning the Led now and again at exceptionally high velocity, it cant be seen by the human eye.
\n\n
So here we develop a data transfer system that uses the Li Fi technology. This system serves the following advantages:\n
• High Speed Data Transfer\n
• No Wires Needed\n
• Reliable Communication with No Data Loss\n
• Low Cost of Developing the System\n
\n
The system makes use of a LDR sensor module along with Atmega Microcontroller, LCD display, basic electronics components, power supply and PCB board to develop this system. The system allows us to use LIFI medium for data transfer. We make use of a LiFi transmitter android app to demonstrate this concept. The app converts written text message into light flash data for transmission. The user needs to start the app and type the message to be transmitted.
\n\n
On sending the message the app controls the mobile phone flashlight to transmit the message. The phone encodes the message into a series of flashed and transmits this data using the mobile torch light. This light message as it falls on the LDR receiver, it is decoded and sent to the microcontroller for processing. The atmega microcontroller decodes and processes the message sent and then displays it over an LCD display to complete the data transmission.');
        PERFORM add_thread('Smart Digital SchoolBell With Timetable Display', 'AnWek', 'School bells have been a critical part of all our childhoods. But with the advent of technology as many things have been digitalized the school bell still remains the same old manual schoolbell. Well lets take the schoolbell too in the new age by making a digital schoolbell which does more than just ringing.
The schoolbell we design is a digital schoolbell which serves the following functions:
\n\n
Storing entire day timetable with timings\n
Sounding buzzer at the end of every period\n
Displaying the name of current and next period\n
Ability to reprogram the board at any time\n
The system makes use of a STM32 controller along with a Bluetooth module, school bell buzzer, LED display 16 x 32 inch along with buttons, basic electronics components and PCB board in order to develop this system. The STM 32 controller uses the display to interact with user. It has a Settings mode and running mode. In the setting mode the system allows user to connect an android device. Once connected we use an app to program the timetable into the system. The android app allows user to set todays timetable in the system with timings.
\n\n
Now when the system is put to running mode, it serves as a digital schoolbell for the day. As per stored timetable it constantly displays the current period running. The STM controller uses internal RTC to eep track of time and display current and next periods. Once the next period timing arrives it shows then next period name and sounds a buzzer as soon as the next period time arrives. This allows for a smart digital schoolbell that also stores timetable and displays it to students and teachers.');
PERFORM add_thread('Ultrasonic Glasses For the Blind','ModeratorTest','Visually impaired people often need assistance in day to day life for navigating through their residence and outside. Having a human assistance is not possible all the time and so a solution to this problem is being researched from a long time.
\n\n
Well here we develop a smart solution to this problem using ultrasonic glasses. Also the glasses are fitted with vibrator rather than a buzzer as constant buzzing sound would be more of a nuisance rather than help. The Smart Glasses would offer the following Advantages:
\n• Ultrasonic Based Obstacle Detection\n
• No Need to Carry System as it is mounted on Wearable Glasses\n
• Silent Vibration Alert on Glasses\n
• Light Weight System\n
The system makes use of 2 x Ultrasonic sensors, an atmega microcontroller, battery, transparent glasses, basic electronics components and a PCB to develop this system. The glasses can now detect obstacles and transmit this to the blind person. The ultrasonic sensors are mounted on glasses on 2 side to act as eyes. The sensors constantly transmit and receive ultrasonic waves to receive obstacle data. The Microcontroller is constantly getting this data from the sensors.
\n\n
Based on this data the microcontroller operates a vibrator motors mounted on the respective side of the glasses. The microcontroller scans the sensor data and the operates the vibrator motors according to the data received in order to get a better understanding of the distance. Thus this system allows blind person to get a more detailed idea of obstacles/objects in front of each eye using vibrations.');
    end;
$add_threads$;

DO
$add_projects_comments$
    BEGIN
        PERFORM add_project_comment(1, NULL, 'mikoWart', 'Jeśli akumulator jest sprawny to taki algorytm wystarczy.
\nInna sprawa kiedy jest wyładowany do 10-20% i żeby odzyskać gęstość elektrolitu trzeba ładować do 16,2V (a to tylko poza samochodem, bo może okazać się niebezpieczne dla instalacji). Co prawda gęstość elektrolitu i witalność wróci też po 2 tygodniach na standbaju - i to jest najpiękniejsze ;)');
        PERFORM add_project_comment(1, 1, 'Justice', 'Mam taki stary akumulator - niby był już do śmieci, ale po 3 cyklach repair do 16,2V odstał swoje i tester już pokazuje go całkiem całkiem jak na to że padł kiedyś do 9,8V. Prądy wg. testera to 533A z deklarowanych 680A. Stoi jako awaryjny, w aucie jeździ nowy już ponad 8 miesięcy.');
        PERFORM add_project_comment(1, 2, 'AnWek', 'Jedyny dystrybutor w PL to Mouser : 50zł/IC + przesyłka za 100zł, do tego obudowa nie do polutowania lutownicą :(');
        PERFORM add_project_comment(1, 3, 'AnWek', 'Tak tylko pytałem się - mój prostownik niby ma korektę i szukałem czegoś czy są na to algorytmy jakieś?
\nZimą zawsze podładowuję do 14,7V żeby aku się lekko podgrzał i nie zasiarczył, a potem podtrzymanie na 13,8V. Prawie ładunku nie wejdzie, ale chyba lekko podtrzyma stan akumulatora.');
        PERFORM add_project_comment(2, NULL, 'AnWek', 'Chylę czoła za ilość pracy w to włożonej. Fakt, urządzenie potrzebne, czasami ratuje tyłek. Przeczytałem dość w pośpiechu dlatego mogłem przeoczyć - regulujesz tu jakoś prąd? Czy urządzenie ma z założenia wyłącznie dopompowywać resztę do akumulatora/ odsiarczać go? Bo jakbyś podłączył ten prostownik do akumulatora rozładowanego (np 10V) to nie dał by rady go naładować, prawda? Przydał by się ogranicznik prądu nawet na te 800mA (nawet na prostym LM317), musiałbyś użyć wyższego napięcia transformatora ale mógłbyś nim ładować prawie wszystko, nawet od 0V.');
        PERFORM add_project_comment(2, NULL, 'AnWek', 'Czy ten biały kabel przeciśnięty przez otwory wentylacyjne, to zasilanie? Jeśli tak, to raczej kiepskie i niebezpieczne rozwiązanie. Szkoda, że wywaliłeś złącze przyłączające zasilanie. To jeden z tych bardziej wartościowych elementów takiego zasilacza podczas przeróbki.');
        PERFORM add_project_comment(2, 5, 'AnWek', 'Ciekawe rozwiązanie.
\nA dorobienie przetwornicy, aby zasilać z innego akumulatora w sposó "przenośniy"?
\nDużo przeróbek by było?');
        PERFORM add_project_comment(2, 6, 'AnWek', 'A nie myślałeś o użyciu specjalizowanego układu typu LTC4162S ?');
        PERFORM add_project_comment(3, NULL, 'AnWek', 'Pomysł na urządzenie do ładowania akumulatorów ciekawy ale już samo wykonanie fatalne.
\n\n
Pozdrawiam');
        PERFORM add_project_comment(3, 9, 'AnWek', 'Rzeźbić zawsze warto. Trzeba trenować szare komórki, bo zanikną nieużywane... ;)
\nA konstrukcja - fakt. Mogła być bardziej dopracowana mechaniczne.');
        PERFORM add_project_comment(3, NULL, 'AnWek', 'Pytanie czy to jest histereza czy regulacja proporcjonalna?');
    end;
$add_projects_comments$;

DO
$add_thread_comments$
    BEGIN
        PERFORM add_thread_comment(1, NULL, 'Pietruszka1', 'magic9 wrote 1147 posts with rating 493, helped 16 times. Live in city Kielce. Been with us since 2010 year.');
        PERFORM add_thread_comment(1, NULL, 'Staszeczek', 'Ciekawe, ciekawe. Przydałoby się kilka przykładów realizacji z klientami tzw. success story.
\n\n
Jaki wyświetlacz i sposób wprowadzania danych przez użytkownika zaproponowalibyście do parkometrów wolnostojących zasilanych z PV ładującuch wbudowane akumulatory?');
        PERFORM add_thread_comment(2, NULL, 'wrocławskiRok', 'Dzięki za artykuł!');
        PERFORM add_thread_comment(2, NULL, 'wrocławskiRok', 'Działają i systemy z Windows 2000. Potem jest problem, bo ludzie w dziale HelpDesk są młodsi niż te systemy. Lepiej takie środowiska izolować niż je aktualizować.');
        PERFORM add_thread_comment(3, NULL, 'wrocławskiRok', 'Trudno mi się odnieść, każdy ma swoją wizję. :)
Osobiście mi wystarczył by zasilacz podtrzymujący 13.6V (z pomiarem temperatury otoczenia żeby podnieść napięcie w zimę, przykładowo do 13.8V przy -10°C, bo jakoś tak wychodzi.)
\n\n
Stojąc całymi dobami na StandBaju i tak i tak doładuje a nawet odsiarczy akumulator (wbrew opiniom niektórych mądrali), a samo zużycie akumulatora będzie marginalne.');
        PERFORM add_thread_comment(3, NULL, 'wrocławskiRok', 'Bardzo dobry pomysł z korektą temperaturową - ciekawe ile takie podtrzymanie zużywa Ah.
\nNapięcie pilnują w lepszych autokomisach - widziałem keidyś jak osbługa na parklingu biegała z prostownikiem i na podtrzymanie wg. harmonogramu doładowywała akumulatory.');
        PERFORM add_thread_comment(3, NULL, 'wrocławskiRok', 'Taka korekta jest od dawien dawna stosowana w zasilaczach buforowych (gdzie pracują akumulatory ołowiowe). Właśnie po to żeby w lecie kiedy jest 30°C napięcie obniżyć do 13.3V (zapobiega wysuszaniu akumulatorów) a w zimie przy -20°C podnieść do 13.8V żeby efektywnie utrzymać naładowanie... (bez gazowania).');
        PERFORM add_thread_comment(4, NULL, 'wrocławskiRok', 'Tak tylko pytałem się - mój prostownik niby ma korektę i szukałem czegoś czy są na to algorytmy jakieś?
\nZimą zawsze podładowuję do 14,7V żeby aku się lekko podgrzał i nie zasiarczył, a potem podtrzymanie na 13,8V. Prawie ładunku nie wejdzie, ale chyba lekko podtrzyma stan akumulatora.');
    end;
$add_thread_comments$;