# 포캣몬 도감

## 주요 기능
* 포켓몬 목록 표시
  * 포켓몬 API를 활용하여 페이징된 데이터 조회
* 포켓몬 상세 정보
  * 포켓몬 이름, 이미지, 타입, 키, 몸무게 등의 상세 정보를 확인
* 이미지 캐싱
  * Kingfisher를 원활한 사용자 경험 제공

## 기술 스택
* 프로그래밍 언어: Swift
* 아키텍처: MVVM
* Reactive Programming: RxSwift, RxCocoa
* 이미지 캐싱 및 로드: Kingfisher
* 레이아웃: SnapKit
* HTTP 통신: URLSession, RxSwift의 Single

## 시연 영상
<div style="display: flex; justify-content: space-between; align-items: center; width: 100%; gap: 10px;">
    <div style="flex: 1; text-align: center;">
        <img src="Image/Gif01.gif" alt="스크롤" style="width: 100%; height: auto;">
        <p>페이징</p>
    </div>
    <div style="flex: 1; text-align: center;">
        <img src="Image/Gif02.gif" alt="디테일" style="width: 100%; height: auto;">
        <p>디테일</p>
    </div>
</div>
