---
name: office-safe
description: >-
  Windows에서 PowerPoint·Word·Excel을 COM으로 다루되 사용자가 열어 둔 작업을 망가뜨리지
  않는다. 먼저 앱이 꺼져 있는지 확인하고, 고치기 전에 백업하고, 사용자가 열어 둔 앱을 끄지
  않는다. Office에서 PDF를 뽑거나 .pptx/.docx/.xlsx를 고칠 때, "PDF로 뽑아줘",
  "파워포인트 고쳐줘"일 때 쓴다.
---

# office-safe (한글판)

Office 자동화는 사용자가 열어 둔 바로 그 앱을 조종하는 일이다. 저장 안 된 작업이 걸려 있다고
생각하고 다룬다. 영어본: `SKILL.md`.

## 1. 건드리기 전에 확인

```powershell
if (Get-Process -Name POWERPNT -ErrorAction SilentlyContinue) { "open" } else { "closed" }
```

앱이 켜져 있으면 **멈추고 묻는다.** 파일을 열지도, 앱을 끄지도 않는다. `$app.Quit()`은
사용자 창을 저장 안 된 문서까지 함께 닫는다. 무엇을 닫아야 하는지 말하고 기다린다.

## 2. 고치기 전에 백업

바꾸기 전에 파일을 시각 그대로 옆 `backup/` 폴더에 복사한다. 이름은 "무엇이었는지"로 짓는다.
덮어쓴 사용자 수정은 되돌릴 수 없고, 백업은 공짜다.

## 3. 라이브러리 우선, 내보내기만 COM

내용 읽기·고치기는 `python-pptx`·`python-docx`·`openpyxl`로 한다. 앱이 필요 없고 위험도 없다.
COM은 그것들이 못 하는 일에만 쓴다. 진짜 PDF 내보내기, 슬라이드 PNG 렌더.

```powershell
$app = New-Object -ComObject PowerPoint.Application
$p = $app.Presentations.Open($path, -1, 0, 0)   # 읽기 전용, 창 없음
$p.Slides(1).Export($png, "PNG", 1200, 1697)
$p.SaveAs($pdf, 32)                              # 32 = PDF
$p.Close(); $app.Quit()                          # 우리가 켰을 때만
```

## 4. 파일 형식이 못 담는 것

- PPTX는 글꼴을 품지 않는다. 상대 컴퓨터에도 있는 글꼴만 쓴다.
- 크기를 지정하지 않은 글자 조각은 테마를 따라가 다른 곳에서 다르게 보인다. 만든 조각마다
  크기·글꼴·색을 지정한다.
- 크기를 바꿀 때는 위치·크기·글자 크기·선 두께·글상자 여백을 모두 같은 비율로 곱한다.

## 5. 밖에서 확인

내보낸 뒤에는 다른 도구로 확인한다. 쪽수, mm 크기, 내장 글꼴, 있어야 할 문구와 없어야 할
문구. `verify-visual` 참고.

## 규칙

- 내가 켜지 않고 붙기만 한 앱에는 절대 `Quit()`을 부르지 않는다.
- 사용자가 열어 뒀을 수 있는 파일에 저장하지 않는다.
- COM 호출이 실패하면 오류를 그대로 보고하고 멈춘다. 바쁜 Office에 재시도하면 파일이 깨진다.
