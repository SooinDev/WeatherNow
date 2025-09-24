# Weather Minimal

미니멀리스트 디자인의 날씨 앱입니다.

## 주요 기능

- 실시간 날씨 정보 조회
- 위치 기반 날씨 데이터
- 미니멀한 UI/UX
- 스와이프 제스처 지원
- 날씨별 배경 애니메이션

## 시작하기

### 사전 요구사항

- Flutter SDK (3.0.0 이상)
- OpenWeatherMap API 키

### 설치 및 설정

1. 저장소를 클론합니다:
```bash
git clone <repository-url>
cd weather_minimal
```

2. 의존성을 설치합니다:
```bash
flutter pub get
```

3. 환경변수를 설정합니다:
   - `.env.example` 파일을 `.env`로 복사합니다
   - [OpenWeatherMap](https://openweathermap.org/api)에서 API 키를 발급받아 `.env` 파일에 설정합니다:
```
WEATHER_API_KEY=your_api_key_here
WEATHER_BASE_URL=https://api.openweathermap.org/data/2.5
```

4. 앱을 실행합니다:
```bash
flutter run
```

## 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **GetX**: 상태 관리 및 라우팅
- **Dio**: HTTP 통신
- **flutter_dotenv**: 환경변수 관리
- **Geolocator**: 위치 서비스
- **Lottie**: 애니메이션
- **SharedPreferences**: 로컬 데이터 저장

## 프로젝트 구조

```
lib/
├── app/                    # 앱 진입점
├── controllers/            # GetX 컨트롤러
├── models/                 # 데이터 모델
├── screens/               # 화면 위젯
│   ├── home/              # 홈 화면
│   ├── splash/            # 스플래시 화면
│   └── weekly/            # 주간 날씨
├── services/              # 외부 서비스
├── utils/                 # 유틸리티 클래스
└── main.dart              # 앱 시작점
```

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
