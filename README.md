# Weather Minimal 🌤️

깔끔하고 미니멀한 디자인의 Flutter 날씨 앱입니다.

## ✨ 주요 기능

- **실시간 날씨 정보** - 현재 위치의 정확한 날씨 데이터
- **주간 날씨 예보** - 5일간의 상세한 날씨 예보
- **미니멀 디자인** - 직관적이고 깔끔한 사용자 인터페이스
- **스와이프 제스처** - 위로 스와이프하여 주간 날씨 보기
- **온도 단위 변환** - 섭씨/화씨 간편 전환
- **날씨별 배경** - 날씨에 따른 동적 배경색 변화
- **위치 기반 서비스** - GPS를 통한 자동 위치 감지
- **스크롤 없는 UI** - 모든 정보를 한 화면에 최적화 표시

## 🚀 시작하기

### 필요 조건

- Flutter SDK (3.0.0 이상)
- Dart SDK
- Android Studio / VS Code
- OpenWeatherMap API 키

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone https://github.com/your-username/weather_minimal.git
   cd weather_minimal
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **환경 설정**
   ```bash
   # .env.example을 .env로 복사
   cp .env.example .env
   ```

4. **API 키 설정**

   [OpenWeatherMap](https://openweathermap.org/api)에서 무료 API 키를 발급받으세요.

   `.env` 파일을 열고 API 키를 입력하세요:
   ```env
   WEATHER_API_KEY=your_actual_api_key_here
   WEATHER_BASE_URL=https://api.openweathermap.org/data/2.5
   ```

5. **앱 실행**
   ```bash
   flutter run
   ```

## 🎯 사용법

### 기본 조작
- **온도 터치**: 섭씨/화씨 단위 전환
- **위로 스와이프**: 주간 날씨 보기
- **아래로 당기기**: 날씨 정보 새로고침

### 권한 설정
앱 실행 시 다음 권한이 필요합니다:
- **위치 권한**: 현재 위치 기반 날씨 정보 제공

## 📦 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **GetX**: 상태 관리 및 라우팅
- **Dio**: HTTP 통신
- **flutter_dotenv**: 환경변수 관리
- **Geolocator**: 위치 서비스
- **Google Fonts**: 폰트 관리
- **SharedPreferences**: 로컬 데이터 저장
- **FL Chart**: 차트 위젯

## 🏗️ 프로젝트 구조

```
lib/
├── controllers/          # GetX 컨트롤러
│   └── app_controller.dart
├── models/              # 데이터 모델
│   ├── weather_model.dart
│   └── location_model.dart
├── screens/             # 화면 위젯
│   ├── home/
│   │   └── widgets/
│   └── weekly/
│       └── widgets/
├── services/            # API 서비스
│   ├── weather_service.dart
│   └── location_service.dart
├── utils/               # 유틸리티
│   ├── colors.dart
│   ├── constants.dart
│   └── text_styles.dart
└── main.dart
```

## 🌍 API 정보

이 앱은 [OpenWeatherMap API](https://openweathermap.org/api)를 사용합니다.

### 사용하는 API 엔드포인트:
- **Current Weather Data**: 현재 날씨 정보
- **5 Day Weather Forecast**: 5일 날씨 예보
- **UV Index**: 자외선 지수 (선택사항)
- **Air Pollution**: 대기질 정보 (선택사항)

## 🛠️ 개발

### 디버그 모드 실행
```bash
flutter run --debug
```

### 릴리즈 빌드
```bash
flutter build apk --release
# 또는 iOS용
flutter build ios --release
```

### 코드 포맷팅
```bash
flutter format .
```

### 테스트 실행
```bash
flutter test
```

## 🤝 기여하기

1. 이 저장소를 포크하세요
2. 새로운 기능 브랜치를 만드세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## ⚠️ 주의사항

- **API 키 보안**: `.env` 파일을 절대 Git에 커밋하지 마세요
- **위치 권한**: 앱이 정상 작동하려면 위치 권한이 필요합니다
- **인터넷 연결**: 날씨 데이터를 위해 인터넷 연결이 필요합니다

## 📞 지원

문제가 발생하거나 질문이 있으시면 Issues를 통해 문의해주세요.

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

**Made with ❤️ in Flutter**
