# Solidity Task
Learn Solidity Make ERC Tokens And Mini Product

1 저금통 → 상태 개념 학습
mapping(address => uint)로 각 사용자 상태 추적
이 개념이 ERC20 balances나 allowances로 확장


2 투표 시스템 → 권한/시간 제어 학습
특정 주소들만 Voter 역할
시간 기반 제어 (5분 후 결과 판별)
-> 이 구조가 Proxy의 onlyAdmin 제어, Upgrade 제한에 연결


3 Multisig Wallet → ECDSA, Off-chain 연동
서명 기반 투표 = 외부에서 Signature 생성, Contract는 검증
Upgrade나 민감한 로직 조작 시 "서명 검증"을 추가로 활용 가능


4 Proxy → delegatecall 개념 정립
상태(State)는 Proxy에만 저장
로직(코드)은 Implementation 교체 가능
EVM 내부에서 Storage, Code 구분되는 원리 실습


5 Upgradeable ERC20 → 실전 시스템 개선
초기 ERC20에서 기능 개선 (Blacklist 필터)
Proxy 주소는 그대로 유지
사용자는 변화를 모르게 무중단 시스템 개선

Token 론칭 후 버그 발견
새로운 규제 대응

기능 추가 (ex. Anti-bot, Blacklist 등)
을 Proxy + Upgrade로 해결하는 패턴 실습


연결성
- DAO 투표 시스템
- 안전한 Multisig 관리 지갑
- Stablecoin Upgrade
- DeFi Contract 개선
같은 실무 기술에 직접 연결되는 구성


결론
상태 관리 → 권한 제어 → 서명 검증 → 로직/상태 분리 → 무중단 시스템 개선
이라는 스마트컨트랙트 핵심 패턴을 점진적으로 연결하는 흐름