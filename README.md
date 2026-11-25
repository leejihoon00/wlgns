# 자격증 길잡이

전공·관심사로 자격증과 진로를 찾고, 공식 시험 일정을 캘린더로 보는 웹페이지예요.
파일 하나(`index.html`)로 되어 있어서 서버 없이 GitHub Pages에 올릴 수 있어요.

## 들어 있는 기능
- 이번 달 접수·시험 일정과 월간 캘린더 (큐넷 등 공식 사이트에서 확인한 2026년 일정)
- 전공 11개·관심사 11개, 자격증 49개 탐색, 검색·필터·비교
- 자격증 상세 정보와 공식 접수 사이트 링크
- 게시판, 구글·이메일 로그인
- 찜, 내 상황(응시 가능 여부 표시), 직접 일정 추가, 찜한 자격증 일정 알림

찜·내 상황·직접 추가한 일정은 **그 기기의 브라우저에만** 저장돼요. PC와 휴대폰 사이에 공유되지 않아요.

## 게시판과 로그인
게시판(글·댓글·도움돼요)과 로그인(구글·이메일)은 Supabase를 써요.
- DB 틀: `supabase/migrations/` 폴더의 SQL
- 글은 누구나 읽을 수 있고, 쓰려면 로그인해야 해요.
- 관리자 지정: Supabase 대시보드 → Table Editor → `profiles`에서 해당 사용자의 `is_admin`을 true로 바꾸면 남의 글·댓글도 지울 수 있어요.
- 로그인 주소 등록: Supabase → Authentication → URL Configuration에 배포 주소를 넣어야 해요.

## 데이터 수정하기
`index.html` 안의 `CERTS`(자격증), `CATS`(전공·관심사), 그 아래 시험일정 부분을 고치면 돼요.
일정은 반드시 주관기관의 공식 공고를 보고 입력하세요.

## GitHub Pages로 올리는 방법
1. GitHub에서 **New repository** → 이름 예: `cert-guide` → Public → Create
2. **uploading an existing file** 링크를 눌러 `index.html`, `README.md`를 끌어다 놓고 **Commit changes**
3. 저장소 **Settings → Pages → Build and deployment**
   - Source: `Deploy from a branch`
   - Branch: `main` / `/ (root)` → **Save**
4. 1~2분 뒤 `https://<내 GitHub 아이디>.github.io/cert-guide/` 로 열려요.

> 정보 기준: 2026년 11월. 시험 일정·응시자격·합격 기준은 바뀔 수 있으니 최종 확인은 공식 사이트에서 하세요.
