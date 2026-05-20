# AGENTS.md

이 저장소는 Swift Package 형태의 `AnimateNumberText` 라이브러리입니다.
작업자는 공개 API 호환성, SwiftUI 사용 흐름, 문서 배포 경로를 함께 확인해야 합니다.

## 프로젝트 기준

- 공개 API는 `Sources/AnimateNumberText/Public/` 아래 타입을 기준으로 봅니다.
- 내부 구현은 `Sources/AnimateNumberText/Private/`에 두고, 공개 타입이 내부 세부사항에 직접 묶이지 않게 합니다.
- 테스트는 `Tests/AnimateNumberTextTests/`의 Swift Testing 기반 테스트를 우선합니다.
- DocC 원본은 `Sources/AnimateNumberText/AnimateNumberText.docc/`입니다.
- `docs/`와 `*.doccarchive/`는 생성 산출물로 봅니다. 리뷰와 커밋에서 우선 제외하고, 문서 배포는 GitHub Actions와 `swift-man/docs` 저장소를 통해 확인합니다.

## 리뷰 제외 기준

`.reviewbot.yml`은 리뷰 프롬프트에서 생성물과 큰 바이너리 리소스를 빼기 위한 운영 설정입니다.

- 리뷰 대상: Swift 소스, `Package.swift`, 테스트, GitHub Actions, DocC 원본 markdown, README, `AGENTS.md`, `.reviewbot.yml`
- 리뷰 제외: `.build/`, `DerivedData/`, `build/`, `dist/`, dependency 폴더, Xcode 사용자 메타데이터, `docs/`, `*.doccarchive/`, `Assets/`, 이미지/영상/오디오 파일
- 항상 리뷰: `.reviewbot.yml`, `AGENTS.md`, `.gitignore`, `README.md`, `GeneratingDocumentationSite`, `Package.swift`, 문서 배포 workflow, DocC 원본 markdown

제외 목록을 넓힐 때는 실제 PR diff에서 불필요하게 모델 입력을 키운 경로인지 먼저 확인합니다. 소스 DocC markdown처럼 사람이 작성한 문서는 생성물과 구분해서 리뷰 대상에 남깁니다.

## SOLID 설계 기준

SOLID는 추상화를 늘리기 위한 구호가 아니라 변경 비용을 줄이기 위한 점검표로 사용합니다.

- 단일 책임: 포맷팅, SwiftUI 표시, 테스트 fixture, 문서 생성 스크립트의 책임을 섞지 않습니다.
- 개방-폐쇄: 새로운 숫자 표시 방식이 필요하면 기존 공개 API 동작을 흔들지 않고 확장할 수 있는지 먼저 봅니다.
- 리스코프 치환: `NumberFormatter`나 `String` formatter를 주입하는 경로는 nil, locale, fraction digit 설정이 달라도 호출 계약을 유지해야 합니다.
- 인터페이스 분리: SwiftUI view 사용자에게 내부 포맷터 세부 옵션을 억지로 노출하지 않습니다.
- 의존성 역전: 공개 view와 formatter는 구체 테스트 환경, 로케일, 문서 배포 스크립트에 의존하지 않게 유지합니다.

작은 패키지이므로 계층을 억지로 늘리지 않습니다. 기존 구조보다 책임이 선명해지고 테스트가 쉬워질 때만 분리합니다.

## 코드 작성 기준

- Swift 코드는 기존 스타일과 공개 API 이름을 존중합니다.
- 로케일, 소수점, 그룹 구분자처럼 실행 환경에 따라 달라지는 값은 테스트에서 명시적으로 고정합니다.
- SwiftUI 상태 변경은 필요한 범위 안에서만 일어나게 하고, view의 입력과 출력이 예측 가능해야 합니다.
- 문서 생성 스크립트는 `docs/`와 `*.doccarchive/` 같은 생성 산출물을 커밋하지 않는 방향으로 유지합니다.
- README와 DocC 예제는 실제 공개 API와 맞아야 합니다.

## 테스트 기준

변경 후 가능한 한 아래를 확인합니다.

```bash
swift test
```

문서 생성이나 배포 workflow를 바꿨다면 아래도 확인합니다.

```bash
DOCS_OUTPUT_PATH=.build/docc-site DOCC_ARCHIVE_PATH=.build/AnimateNumberText.doccarchive ./GeneratingDocumentationSite
```

테스트를 못 돌렸다면 PR 댓글에 어떤 명령을 못 돌렸고 왜 못 돌렸는지 남깁니다.

## PR 리뷰 대응

PR 리뷰 봇의 지적은 그대로 수용하지 말고 최신 HEAD의 실제 코드와 diff를 확인해 합리적 지적과 환각을 구분합니다.

- 합리적 지적이면 수정하고, 원 댓글의 대댓글에 `수정 완료`로 시작해 무엇을 바꿨는지와 검증 명령을 적습니다.
- 지적이 환각이면 원 댓글의 대댓글에 `보류`로 시작해 최신 코드 기준으로 왜 발생할 수 없는지 설명합니다.
- 판단이 아직 부족하면 `추가 확인 필요`로 시작해 어떤 정보나 재현 조건이 필요한지 적습니다.
- 같은 내용을 여러 봇이 반복했다면 대표 댓글에 답하고, 나머지에는 같은 수정으로 해결됐다고 짧게 답합니다.
- 라인 코멘트가 아닌 전체 리뷰 본문에서 나온 이슈도 PR 일반 댓글로 처리 결과를 남깁니다.

댓글을 남기기 전에는 아래를 확인합니다.

- 최신 PR HEAD의 파일과 라인을 직접 확인했는가
- 이미 근처 코드나 테스트가 해당 조건을 처리하고 있지 않은가
- 실제 입력, 상태, 실행 순서로 문제가 재현 가능한가
- false positive가 missed suggestion보다 더 해롭다고 가정해도 남길 코멘트인가

## 재시동 및 재실행 안내

이 저장소 자체는 라이브러리라 일반 코드 변경 후 서버 재시동은 없습니다.

다만 아래 변경은 후속 안내가 필요합니다.

- GitHub Actions 또는 배포 설정 변경: 다음 push 또는 `workflow_dispatch`에서 적용된다고 안내합니다.
- 문서 생성 스크립트 변경: 위 DocC 생성 명령을 다시 실행하라고 안내합니다.
- `.reviewbot.yml` 또는 `AGENTS.md` 변경: 리뷰 봇은 PR HEAD의 파일을 읽으므로 별도 서버 재시동은 필요 없고, 새 리뷰 실행부터 적용된다고 안내합니다.
- 로컬 preview, Xcode preview, 테스트 watcher를 켜 둔 상태라면 해당 프로세스를 재실행하라고 안내합니다.
