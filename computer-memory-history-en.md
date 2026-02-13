# From Mercury to Silicon: The Crazy Evolution of Computer Storage Technology

Imagine if someone told you that early computers stored data in mercury tubes, used TV screens as memory, and relied on hand-woven copper wires for storage—would you think it was science fiction? Yet these seemingly absurd technologies are real chapters in the history of modern computer development.

In our age of solid-state drives and memory modules, looking back at the evolution of computer storage technology reveals a fascinating pattern: every generation of seemingly "absurd" technical solutions was actually the optimal choice for engineers working within the physical limitations and cost constraints of their time. Technological progress has never been a linear leap forward, but rather a continuous process of finding breakthroughs through trial and error.

## Mercury Memories: The Era of Delay-Line Storage

Our story begins in the 1940s. At that time, newly born electronic computers faced a fundamental problem: how to store data and programs? While vacuum tubes could perform logical operations, using them for storage was extremely expensive—each bit required a vacuum tube, and a decent computer needed to store thousands of bits.

It was then that a storage solution adapted from radar technology took the stage: Mercury Delay Line Memory. Its operating principle sounds like magic: piezoelectric transducers are placed at both ends of a tube filled with mercury. When storing data, electrical pulses are converted to sound waves and sent into the mercury, where they travel at 1,450 meters per second to the other end of the tube, then are received by the transducer and converted back to electrical signals. By continuously cycling this process, data is "stored" in the sound waves.

EDSAC (1949) and UNIVAC I (1951) both used this technology. EDSAC's 16 delay-line tubes could store a total of 256 35-bit words, with each tube capable of storing 560 bits—quite substantial capacity for its time. But the cost was equally substantial: these mercury tubes required precise temperature control (40°C), because the speed of sound in mercury is extremely temperature-sensitive. Moreover, mercury is highly toxic, requiring maintenance personnel to work in high-temperature, toxic environments.

Even more interesting, these mercury tubes made sounds resembling muffled human speech when operating, earning them the nickname "mumble-tub" from engineers. Imagine the scene in computer rooms of that era: rows of mercury tubes "mumbling" at 40°C—both mysterious and somewhat eerie.

## Rhythm of Algorithms: Drum Storage and Early Performance Optimization

If mercury delay-line storage was the "Stone Age" of storage technology, then Drum Memory represented the "Bronze Age." This device, invented by Austrian inventor Gustav Tauschek in 1932, was essentially a metal cylinder with a magnetic coating on its surface.

Drum storage worked in a relatively straightforward manner: the cylinder rotated continuously while read-write heads moved along the cylinder surface, recording or reading data on the magnetic coating. But what was truly interesting was this technology's impact on programming methods. Since data was stored on a rotating drum surface, programmers had to precisely calculate instruction execution times, then place the next instruction at a precisely calculated position on the drum so that when the CPU finished executing the current instruction, the next instruction would rotate exactly under the read-write head.

This technique, called "skip factor" or "interleaving," could be considered the earliest performance optimization in computer history. Programmers needed to deeply understand the physical characteristics of hardware, calculating timing with watchmaker-like precision. IBM even developed an assembler called SOAP (Symbolic Optimal Assembly Program) specifically for automatic timing optimization.

The IBM 650 (1954) was the first mass-produced computer using drum storage, initially capable of storing 2,000 10-digit words (about 17.5KB), later increased to 4,000 words (about 35KB). For us today, 35KB can't even store a high-definition photo, but in that era, this was already "massive storage."

## Women's Woven Memories: The Era of Magnetic Core Storage

In the 1950s, a truly revolutionary storage technology emerged: Magnetic Core Memory. The core of this technology (yes, the word "core" comes from here) consisted of countless small iron rings just a few millimeters in diameter, each capable of storing one bit of information.

Magnetic core memory's operating principle was based on magnetic hysteresis: by controlling the direction of current flowing through the iron rings, the rings could maintain either clockwise or counterclockwise magnetization states, representing 1 and 0 respectively. More ingeniously, this storage used "half-select current" technology—only the intersection where X and Y lines simultaneously carried half-amplitude current could change the ring's state, enabling precise selection of any storage unit in a planar array.

But what was most impressive about magnetic core memory wasn't its technical principle, but its manufacturing process. Every storage plane required hand weaving: workers (mainly women) needed to use microscopes to thread copper wires as thin as hair strands through tens of thousands of small iron rings, one by one. This was work requiring enormous patience and fine motor skills—assembling a 128×128 core array required 25 hours of hand threading.

MIT's "Moby Memory" was the masterpiece of the magnetic core memory era—this 256K-word (1.2MB) storage system was considered "unimaginably huge" in 1967, cost $380,000, and had dimensions of 175cm×127cm×64cm, equivalent to a large refrigerator.

Magnetic core memory also had a characteristic that modern people find incredible: it was non-volatile. Even when powered off, data remained in those small iron rings. In a sense, this was more advanced than our current DRAM. When computers had problems requiring analysis, engineers would dump the entire contents of core memory to magnetic tape for analysis—this is the origin of the term "core dump," which we still use today when programs crash.

## Screens Not for Viewing: The Ingenious Williams Tube

Before magnetic core memory became mainstream, there was an even more peculiar storage technology: the Williams Tube. This device, invented by Britons Freddie Williams and Tom Kilburn, was essentially a cathode-ray tube display—but it wasn't used for display; it was used for data storage.

The Williams tube exploited an interesting physical phenomenon of CRTs: when an electron beam strikes phosphor, it produces secondary electron emission, creating a small positively charged pit and surrounding negatively charged area on the phosphor surface. This charge distribution can be maintained for a short time, just enough to represent one bit of information.

The entire screen was densely covered with such "charge dots," each representing one bit. To read data, the electron beam would scan these positions again; if there was originally a charge well, no current would be produced; if there wasn't, the scanning process would generate a current pulse. This "destructive readout" meant that each read would destroy the original data, requiring immediate rewriting.

The Williams tube was the world's first random-access storage device, providing storage for the Manchester "Baby" computer that first successfully ran a program on June 21, 1948. But it was also extremely unstable, requiring frequent manual adjustments and being extremely sensitive to nearby electrical field interference. Nevertheless, many important computers including UNIVAC 1103, IBM 701, and 702 all used this technology.

## Programs on Paper: The Era of Punched Cards and Tapes

While we've been discussing electronic storage technologies, we cannot forget a storage medium with even more far-reaching impact: punched cards. As early as the 1890 U.S. Census, Herman Hollerith invented methods for data processing using punched cards. IBM's predecessor—the Tabulating Machine Company—was founded on punched card technology.

A standard IBM punched card had 80 columns, each capable of 12 holes, storing 80 characters of information. This storage density was minuscule by today's standards but revolutionary in the age of mechanical computation. Programmers needed to punch entire programs and data onto thousands of cards; if there was a mistake or cards got out of order, the program couldn't run.

"Do not fold, spindle or mutilate" printed on cards became a collective memory for an entire generation of programmers. In that era, a large program might require several boxes of punched cards, and programmers' daily work included transporting and organizing these cards.

## Future in Bubbles: The Flash of Magnetic Bubble Memory

In the 1970s, Bell Labs developed what was believed to be a new invention that would "revolutionarily change storage technology": Magnetic Bubble Memory. This technology utilized the ability of certain magnetic materials to form stable microscopic magnetic domains (magnetic bubbles) that could be moved under magnetic field control, with each bubble representing one bit.

The advantages of magnetic bubble memory seemed obvious: it was solid-state with no mechanical moving parts; non-volatile, retaining data when powered off; and theoretically could be made very small. Intel, TI, and other companies invested heavily in developing this technology, believing it would replace magnetic disks as the primary storage technology.

However, history chose a different direction. In the 1980s, the emergence of flash storage technology completely changed the game. Flash storage not only had all the advantages of magnetic bubble memory but was also cheaper, had larger capacity, and was faster. Magnetic bubble memory quickly went from "future technology" to historical artifact, reminding us that the path of technological development is never accurately predictable.

## Wild Experiments: Strange Storage Solutions

Computer development history is full of even more peculiar storage attempts. For instance, Alan Turing once suggested using gin as an ultrasonic delay medium, reasoning that it had suitable acoustic properties—though this suggestion obviously contained British humor, it also reflected early engineers' exploration of various possibilities.

There was also a technology called Twistor Memory, developed by Bell Labs, which used combinations of thin copper wires and magnetic thin films to store information. Another type, CCD memory (not the camera kind), utilized charge-coupled devices to store digital information.

Some even tried using alcohol instead of mercury as delay-line medium—alcohol had slower sound velocity but was much cheaper than mercury and non-toxic. Most of these attempts didn't achieve commercial success, but they demonstrated early engineers' innovative spirit and continuous exploration of technological boundaries.

## The Weaving Craft Behind Apollo Moon Landing

Speaking of magnetic core memory, one amazing application must be mentioned: the Core Rope Memory of the Apollo Guidance Computer. This read-only memory was even more complex to manufacture: to store "1" at a specific address, copper wire would pass through the corresponding magnetic core; to store "0," wire would pass around the core.

Each storage module of the Apollo Guidance Computer was hand-woven by specially trained women workers. Under microscopes, they had to thread extremely thin copper wires through dense arrays of magnetic cores according to strict patterns. Weaving one module took several weeks, with no room for error—because these storage devices would be sent 380,000 kilometers away to the Moon.

In a sense, humanity's successful moon landing depended not only on rocket technology and astronaut courage but also on the exquisite craftsmanship of those anonymous weaving women on Earth. Using the most traditional hand-weaving techniques, they created the most advanced space technology.

## Time's Spiral: From Absurd to Obvious

Reviewing this history, we discover an interesting pattern: yesterday's "absurd technology" often becomes the predecessor of today's obvious technology. Mercury delay-line storage seemed absurd but pioneered electronic storage; drum storage's timing optimization techniques evolved into modern operating system scheduling algorithms; magnetic core memory's hand-weaving crafts laid the foundation for modern integrated circuit manufacturing precision.

Even seemingly failed technologies found new life in other fields. While magnetic bubble memory lost in the computer storage market, related technologies were later applied to magnetic sensors and magneto-optical devices. The Williams tube principle inspired later CCD image sensor development.

## Future "Mercury Storage"

Standing at today's point in time, it's easy to mock past "absurd" technical solutions. But if we fast-forward 50 years, future people reviewing our technology might have similar feelings:

"Can you believe it? They actually used silicon chips to store data, and needed constant refreshing to maintain information! Their 'solid-state drives' actually had electrons tunneling through insulating layers! Most incredible of all, they used photolithography to carve circuits at nanometer scales—it's like using an elephant's foot to write on rice grains!"

Perhaps what we consider obvious today—DDR5 memory and NVMe SSDs—will be tomorrow's "mercury delay lines" to future people. And the quantum storage, DNA storage, and photonic storage technologies we're exploring now might be the starting points for the next generation of "absurd technologies."

## The Nature of Technological Progress

This history of computer storage technology development tells us an important truth: the nature of technological progress is not linear optimization, but the process of finding optimal solutions under constraints. Every generation of engineers faces similar challenges: finding the best balance between cost, performance, reliability, and manufacturing processes.

When transistors weren't yet invented, mercury delay lines were the best choice; when integrated circuits were still in laboratories, hand-woven magnetic core memory was the most reliable solution; when semiconductor processes weren't mature, mechanical disk drives were the most economical solution.

Behind every "absurd" technical solution was a group of smart engineers making rational choices under existing conditions. They might not have anticipated their technology being replaced by later solutions, but it was their efforts and exploration that paved the way for subsequent technological breakthroughs.

## The Eternal Spirit of Exploration

From mercury tubes to silicon chips, from hand weaving to photolithography, the development history of computer storage technology is a vivid portrayal of human wisdom and creativity. Behind every technological revolution are countless hours of hard work by engineers, scientists, and workers.

Just as we cannot predict what storage technology will look like in 50 years, the engineers of yesteryear could not imagine today's SSDs and cloud storage. But one thing is certain: as long as humanity's need for information storage and processing continues to exist, new "absurd" technical solutions will continuously emerge, then become "obvious" existences in the long river of history.

Perhaps this is the most fascinating aspect of technological progress: today's impossibility might be tomorrow's obviousness; today's absurdity might be the day after tomorrow's classic. In this endless process of exploration, every generation of technical people are both participants and witnesses to history.

From mercury's mumbling to SSD's silence, this path of technological evolution has been winding yet spectacular. And our story continues to be written...

---

*(Approximately 3,500 words)*

**References:**
- Williams, F.C.; Kilburn, T. "Electronic Digital Computers", Nature, 1948
- Forrester, Jay W. "Digital Information Storage In Three Dimensions Using Magnetic Cores", Journal of Applied Physics, 1951
- Eckert, J. Presper "A Survey of Digital Computer Memory Systems", Proceedings of the IRE, 1953
- "Magnetic-core memory" Wikipedia contributors. Wikipedia, The Free Encyclopedia
- "Delay-line memory" Wikipedia contributors. Wikipedia, The Free Encyclopedia
- "Drum memory" Wikipedia contributors. Wikipedia, The Free Encyclopedia