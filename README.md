
# 0xRoyalties
0xRoyalties is a group of contracts to generically license your work and sign agreements on a public distributed ledger.

These contracts are saving the small players in royalty payment-based industries from counter-party risk, level the playing field in these industries by making the licensing terms public to all, and help enable reliable and trustless payment through immutable smart contracts.


## ABOUT
Allows products to focus on the products that they are tokenizing using this as a template, saving those teams gas to deploy this common functionality.

We're open sourcing this to call on a broader brain trust to address design issues 

## TECHNICAL NOTES:
All contracts that use AccessController are Pausable.
Licensing will integrate requiring ERC721.approve()
Upgradability pattern that may be added may affect the ABI


## CLASS DIAGRAMS
The below diagrams illustrate a high-level view of 0xRoyalties core functionality. THey are followed by the recursion problem that we face and aspire to optimize or rework to prevent expensive transactions for the end user:

<img src="./docs/Class_Diagrams/0xR_CD1.jpg" align="center" />
<img src="./docs/Class_Diagrams/0xR_CD2.jpg" align="center" />
<img src="./docs/Class_Diagrams/0xR_CD3a.jpg" align="center" />
<img src="./docs/Class_Diagrams/0xR_CD3b.jpg" align="center" />
<img src="./docs/Class_Diagrams/0xR_CD4.jpg" align="center" />

<img src="./docs/Recursion_issue_Java_example/rescursion_issue_a.jpg" align="center" />
<img src="./docs/Recursion_issue_Java_example/rescursion_issue_attemptedsolution_1.jpg" align="center" />
<img src="./docs/Recursion_issue_Java_example/rescursion_issue_problem_statement.jpg" align="center" />