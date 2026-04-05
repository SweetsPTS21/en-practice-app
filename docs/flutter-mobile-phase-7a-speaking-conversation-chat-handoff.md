# Flutter Mobile Phase 7A Handoff

Tài liệu này mô tả sub-phase triển khai chi tiết nằm bên trong `flutter-mobile-phase-7-productive-skills-speaking-writing-handoff.md`.

Nếu phase 7 là productive skills parity ở mức toàn cụm, thì phase 7A là lát cắt hẹp hơn:

- khóa `speaking conversation chat` trên mobile
- reuse layout chat cơ bản đã có ở mobile
- ưu tiên wiring logic, state, route, realtime và fallback thay vì dựng thêm UI mới

Tên ngắn gọn nên dùng:

`Phase 7A - Speaking Conversation Chat Functionality`

Nếu muốn tên kỹ thuật hơn:

`Phase 7A - Custom Speaking Conversation Chat, Recorder State, Realtime Turn Loop, And Result Handoff`

## 1. Kết Luận Sau Khi Đọc Toàn Bộ Luồng Speaking

Sau khi rà soát docs, API, speaking list, speaking practice, guided conversation, custom conversation, result/history và learning analytics, có 7 kết luận quan trọng.

### 1.1. Speaking web hiện có 4 loop riêng nhưng chat chỉ nằm ở 2 loop cuối

Các loop hiện tại của speaking là:

- `Speaking practice` kiểu single-attempt: chọn topic, ghi âm hoặc nhập transcript, submit, chờ grading
- `Guided speaking conversation`: vào từ topic IELTS, chat qua nhiều turn với AI
- `Custom speaking conversation`: tự cấu hình topic và persona rồi chat
- `Result/history revisit`: quay lại transcript, feedback, completion snapshot

Điều này có nghĩa phase 7A không cần kéo cả speaking vertical vào cùng lúc. Nó chỉ cần khóa tốt lớp chat dùng trong 2 conversation loops.

### 1.2. Guided conversation và custom conversation dùng chung 1 chat shell nhưng orchestration khác nhau

Hai flow đều có:

- danh sách message `ai` và `user`
- recorder + transcript + speech analytics
- AI audio playback
- typing/loading indicator
- auto-scroll
- trạng thái khóa input khi conversation không còn active

Nhưng khác nhau ở orchestration:

- `Guided conversation` start bằng `topicId`, route là `/speaking/conversation/:topicId`, không có setup form riêng, không có nút finish rõ ràng, backend tự complete khi đủ turn
- `Custom conversation` start bằng form cấu hình, route là `/custom-speaking/conversation/:id`, có resume bằng `conversationId`, có nút finish, có snapshot local để khôi phục prompt cuối

### 1.3. Web hiện không yêu cầu audio upload để chat hoạt động

Điểm này rất quan trọng cho mobile scope.

Trong cả:

- `src/pages/speaking/SpeakingConversationPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationChatPage.jsx`

payload submit turn thực tế chỉ gửi:

- `transcript`
- `timeSpentSeconds`
- `speechAnalytics`

`audioUrl` có trong contract doc nhưng chưa phải dependency bắt buộc của chat flow hiện tại. Nghĩa là phase 7A không nên block vào audio upload hoặc audio persistence.

### 1.4. Custom conversation là flow chat trưởng thành hơn và nên là trọng tâm của 7A

Custom flow hiện có đầy đủ hơn guided flow ở các điểm:

- setup page riêng
- REST start rõ ràng
- snapshot local để resume
- WebSocket realtime ưu tiên nhưng có REST fallback khi publish fail
- explicit finish flow
- history mở lại route chat nếu status vẫn `IN_PROGRESS`
- result page có completion snapshot và recommendation surface
- analytics start/completion đã cắm sẵn

Vì vậy, phase 7A nên ưu tiên `custom speaking conversation chat` trước. Kiến trúc phải đủ generic để guided conversation reuse sau đó mà không refactor lớn.

### 1.5. Resume và locked-state là phần không được bỏ sót ở mobile

Web custom chat page không chỉ render chat:

- lúc vào page, nó luôn load detail conversation từ backend
- merge detail với `bootstrap state` từ route và `snapshot` trong local storage
- append lại prompt AI cuối nếu backend detail chưa kịp phản ánh turn mới nhất
- khóa toàn bộ input khi status là `COMPLETED`, `GRADING`, `GRADED` hoặc `FAILED`
- redirect sang result page nếu conversation đã không còn `IN_PROGRESS`

Nếu mobile chỉ implement gửi/nhận tin nhắn mà bỏ resume + locked-state, trải nghiệm sẽ lệch khá xa so với web.

### 1.6. Async grading thực chất bắt đầu sau khi conversation complete, không phải trong lúc chat

State machine backend cho custom conversation là:

- `IN_PROGRESS`
- `COMPLETED`
- `GRADING`
- `GRADED`
- `FAILED`

Chat page chỉ nên cho nhập khi đang `IN_PROGRESS`. Sau khi finish hoặc backend complete:

- input bị khóa
- user được đưa sang result
- result page mới là nơi poll detail cho đến `GRADED` hoặc `FAILED`

### 1.7. Có contract mismatch cần chốt trước khi hard-code mobile options

`docs/custom-speaking-conversation-fe.md` hiện mô tả:

- 4 `style`
- 4 `personality`
- 5 `expertise`
- không nhắc `voiceName`

Nhưng web code hiện đang dùng:

- danh sách option mở rộng hơn trong `src/utils/speaking.js`
- trường `voiceName` trong setup page, snapshot, realtime response và result page

Kết luận:

- phase 7A phải xác nhận lại backend contract thật trước khi khóa enum trong mobile
- nếu chưa xác nhận được, mobile chỉ nên dùng tập option đã backend xác thực hoặc làm config mềm

## 2. Phase 7A Là Gì

Phase 7A là phase biến layout chat đang có ở mobile thành flow chức năng thật cho speaking conversation.

Trọng tâm thực thi là:

- `CustomSpeakingConversationPage.jsx`
- `CustomSpeakingConversationChatPage.jsx`
- shared recorder / transcript / chat state

Guided conversation vẫn phải được đọc kỹ và phản ánh vào kiến trúc, nhưng không cần ép parity 100% ngay trong cùng lát cắt nếu làm vậy khiến scope phình quá nhanh.

Sau phase 7A, mobile nên làm được tối thiểu:

1. user mở custom speaking setup
2. user start conversation thành công
3. user nói hoặc nhập transcript để gửi turn
4. app nhận AI reply qua WS hoặc REST fallback
5. user finish conversation
6. app chuyển đúng sang result route
7. user mở lại conversation đang dang dở từ history hoặc deep link mà không mất context

## 3. In Scope

- custom speaking setup form và route start conversation
- custom speaking chat page với state thật
- load detail theo `conversationId`
- merge bootstrap state + backend detail + local snapshot
- realtime STOMP subscribe cho custom conversation
- REST fallback khi WS publish fail
- recorder state, timer, transcript và speech analytics payload
- manual transcript fallback nếu live STT chưa sẵn hoặc không khả dụng
- AI audio playback và nút replay prompt gần nhất
- turn counter, grading badge, status badge, connection badge
- finish conversation flow
- locked-state banner khi conversation không còn active
- navigation sang result route sau completion
- nền tảng shared model/controller để guided conversation có thể reuse ở phase kế tiếp

## 4. Out Of Scope

- visual redesign cho chat layout
- audio upload trong chat flow
- token-level streaming kiểu `/realtime-chat`
- coaching overlay, inline correction, retry per bubble
- result page polish vượt quá route handoff cơ bản
- custom conversation enum expansion nếu backend chưa chốt
- offline queue cho recorder hoặc submit turn
- guided conversation full parity nếu chưa cần ship ngay trong cùng slice

## 5. Source Of Truth Cần Bám

### 5.1. Docs

- `docs/mobile/flutter-mobile-phase-7-productive-skills-speaking-writing-handoff.md`
- `docs/custom-speaking-conversation-fe.md`
- `docs/realtime-chat-streaming-spec.md`

### 5.2. Web reference implementation

- `src/api/speakingApi.js`
- `src/pages/speaking/SpeakingListPage.jsx`
- `src/pages/speaking/SpeakingConversationPage.jsx`
- `src/pages/speaking/SpeakingConversationResultPage.jsx`
- `src/pages/speaking/SpeakingConversationHistoryPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationChatPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationResultPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationHistoryPage.jsx`
- `src/hooks/useConversationStomp.js`
- `src/hooks/useCustomConversationStomp.js`
- `src/hooks/useWsSpeechRecording.js`
- `src/utils/customSpeakingConversationStorage.js`
- `src/utils/speaking.js`
- `src/features/learning/learningAnalytics.js`

## 6. Mapping Logic Web Cần Giữ Khi Port Sang Mobile

### 6.1. Entry points

`SpeakingListPage` hiện có 3 entry liên quan tới conversation:

- `/speaking/conversation/:topicId` cho guided conversation
- `/custom-speaking` cho custom setup
- `/speaking/conversation/history` và `/custom-speaking/history` cho revisit

Phase 7A không nhất thiết phải port hết toàn bộ list page, nhưng route contract và re-entry behavior phải tương thích.

### 6.2. Custom start flow

Custom setup page hiện làm đúng 4 việc:

1. validate `topic`
2. gọi `POST /api/custom-speaking-conversations/start`
3. lưu snapshot local với `title`, `topic`, `latestAiMessage`, `gradingEnabled`, `status`, `userTurnCount`, `maxUserTurns`, `voiceName`
4. navigate sang `/custom-speaking/conversation/:conversationId` và truyền `bootstrap`

Điểm quan trọng:

- custom start hiện là REST-first, không phải WS-first
- đây là lựa chọn hợp lý cho mobile 7A vì đơn giản và ổn định hơn

### 6.3. Chat bootstrap flow

Khi mở custom chat page, web làm các bước sau:

1. đọc `bootstrap` từ route state
2. đọc snapshot local theo `conversationId`
3. gọi `GET /api/custom-speaking-conversations/{id}`
4. map `turns` thành message list
5. nếu snapshot còn giữ `latestAiMessage` nhưng detail chưa phản ánh prompt cuối, append thêm AI message pending
6. nếu status khác `IN_PROGRESS`, redirect sang `/custom-speaking/result/:id`

Đây là behavior rất đáng giữ vì nó giải được case:

- app bị kill giữa conversation
- user mở lại từ history
- response AI vừa nhận xong nhưng detail backend chưa kịp đồng bộ hoàn toàn

### 6.4. Submit turn flow

Custom chat page hiện submit theo thứ tự:

1. stop recording
2. chờ `speech_summary` từ STT socket với timeout ngắn
3. normalize speech analytics
4. lấy transcript cuối
5. append optimistic user bubble
6. clear transcript input
7. thử publish STOMP `submit`
8. nếu publish fail thì fallback sang REST `POST /api/custom-speaking-conversations/{id}/turn`
9. xử lý AI response và update snapshot

Điểm đáng lưu ý:

- web không rollback optimistic bubble nếu submit fail
- phase 7A không cần làm retry per message; toast error là đủ để giữ scope gọn

### 6.5. Finish flow

Custom chat page finish như sau:

1. nếu đang recording thì cancel trước
2. set submitting state
3. thử publish STOMP `finish`
4. nếu publish fail thì fallback sang REST `POST /api/custom-speaking-conversations/{id}/finish`
5. coi response như `CONVERSATION_COMPLETE`
6. clear snapshot local
7. navigate sang result route sau delay ngắn

Vì vậy mobile không cần modal confirm phức tạp trong phase đầu. Chỉ cần behavior finish đúng và không để user gửi thêm turn sau đó.

### 6.6. AI playback flow

Web custom chat page play giọng AI theo ưu tiên:

1. nếu realtime payload có `audioBase64` thì phát audio đó
2. nếu không có thì fallback sang local TTS với `voiceName`

Ngoài ra còn có auto-play prompt gần nhất khi:

- page vừa load xong
- conversation đang `IN_PROGRESS`
- chưa auto-play prompt đó trước đây

Mobile 7A nên giữ:

- auto-play prompt đầu
- nút replay prompt gần nhất

Nhưng không cần build advanced audio queue.

### 6.7. Locked-state và result handoff

Chat page custom coi conversation là locked nếu status thuộc:

- `COMPLETED`
- `GRADING`
- `GRADED`
- `FAILED`

Khi locked:

- ẩn toàn bộ control gửi turn
- hiện banner giải thích conversation không còn active
- cho CTA mở result page

Đây là phần bắt buộc vì history route có thể mở lại cả conversation cũ.

### 6.8. Guided conversation khác gì và cần giữ điều gì cho kiến trúc

Guided flow hiện có các đặc điểm riêng:

- route start theo `topicId`, không phải `conversationId`
- start qua STOMP `/app/speaking-conversation`
- submit turn qua REST `/api/speaking/conversations/{conversationId}/turn`
- AI response có `aiQuestion`, `lastTurn`, `turnType`
- có `HINT` turn riêng
- khi complete thì append system message rồi auto navigate sang result

Kết luận cho phase 7A:

- shared message model nên có `turnType`
- shared chat shell nên không hard-code `custom only`
- nhưng orchestration start/submit/finish nên tách controller riêng cho guided và custom

## 7. Transport Và Contract Matrix Nên Áp Dụng Ở Mobile

| Flow               | Web hiện tại                     | Khuyến nghị mobile 7A                                         |
| ------------------ | -------------------------------- | ------------------------------------------------------------- |
| Custom start       | REST                             | REST                                                          |
| Custom submit turn | STOMP ưu tiên, REST fallback     | Giữ nguyên                                                    |
| Custom finish      | STOMP ưu tiên, REST fallback     | Giữ nguyên                                                    |
| Custom detail      | REST                             | REST                                                          |
| Custom history     | REST                             | REST                                                          |
| Guided start       | STOMP                            | Có thể giữ riêng cho phase sau                                |
| Guided submit turn | REST                             | Có thể reuse sau                                              |
| Live STT           | Raw WebSocket `/ws/speaking/stt` | Nếu chưa chắc trên Flutter, cho phép transcript fallback ngay |

Custom conversation endpoints hiện cần bám:

- `POST /api/custom-speaking-conversations/start`
- `POST /api/custom-speaking-conversations/{id}/turn`
- `POST /api/custom-speaking-conversations/{id}/finish`
- `GET /api/custom-speaking-conversations/{id}`
- `GET /api/custom-speaking-conversations`
- `GET /api/user/results/custom-conversations/{id}/completion-snapshot`

Realtime endpoints:

- STOMP handshake: `/ws/realtime-chat`
- STOMP subscribe: `/topic/custom-speaking-conversation/{userId}`
- STOMP publish: `/app/custom-speaking-conversation`

STT endpoint:

- raw WebSocket: `/ws/speaking/stt?token=<access_token>`

### 7.1. Response Wrapper Convention

Web `axiosClient` hiện unwrap response theo rule chung:

- nếu backend trả `{ success, message, data }` thì FE thực tế chỉ nhận `data`
- nếu `success = false` thì FE ném `ApiError`

Vì vậy mobile nên hiểu đồng thời 2 lớp contract:

- `raw backend response`
- `normalized object` sau khi network layer unwrap

Mọi ví dụ bên dưới sẽ ghi rõ khi cần:

- `Raw response`
- `After unwrap`

### 7.2. Shared Payload Và Model Contract

#### 7.2.1. Speech analytics payload

Payload speech analytics đang được custom chat và guided chat gửi theo shape sau:

```json
{
    "wordCount": 15,
    "wordsPerMinute": 112.5,
    "pauseCount": 2,
    "avgPauseDurationMs": 720,
    "longPauseCount": 0,
    "fillerWordCount": 1,
    "fillerWords": ["um"],
    "avgWordConfidence": 0.91,
    "lowConfidenceWords": ["classrooms"],
    "wordDetails": []
}
```

Ghi chú:

- `audioUrl` là optional trong contract, không phải blocker của phase 7A
- web hiện normalize từ STT summary về các key trên trước khi submit
- `wordDetails` có thể là mảng rỗng

#### 7.2.2. Custom conversation status

```json
["IN_PROGRESS", "COMPLETED", "GRADING", "GRADED", "FAILED"]
```

#### 7.2.3. Guided conversation status

Từ result/history page, guided conversation ít nhất đang dùng:

```json
["IN_PROGRESS", "COMPLETED", "GRADING", "GRADED", "FAILED"]
```

Phần này chưa có doc contract riêng trong repo, nhưng toàn bộ UI đang giả định cùng status family với custom conversation.

#### 7.2.4. Voice field

`voiceName` hiện:

- được web setup page gửi lên backend
- được chat/result page đọc từ response hoặc snapshot
- chưa xuất hiện trong `docs/custom-speaking-conversation-fe.md`

Do đó mobile phải coi `voiceName` là:

- `optional`
- `implementation-observed`
- cần confirm lại với backend trước khi khóa enum

### 7.3. Custom Conversation REST Contracts

#### 7.3.1. Start custom conversation

`POST /api/custom-speaking-conversations/start`

Request:

```json
{
    "topic": "How technology changes the way people learn",
    "style": "PROFESSIONAL",
    "personality": "PATIENT",
    "expertise": "EDUCATION",
    "gradingEnabled": true,
    "voiceName": "US_NEURAL_J"
}
```

Ghi chú:

- `voiceName` là field web đang gửi, nhưng chưa có trong doc backend hiện tại
- nếu backend chưa nhận field này thì mobile phải cho phép omit

Raw response:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "title": "Learning With Technology",
        "turnNumber": 1,
        "aiMessage": "Technology has changed learning in many interesting ways. From your point of view, what is the biggest change it has made for students?",
        "conversationComplete": false,
        "gradingEnabled": true,
        "status": "IN_PROGRESS",
        "userTurnCount": 0,
        "maxUserTurns": 100,
        "voiceName": "US_NEURAL_J"
    }
}
```

After unwrap:

```json
{
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 1,
    "aiMessage": "Technology has changed learning in many interesting ways. From your point of view, what is the biggest change it has made for students?",
    "conversationComplete": false,
    "gradingEnabled": true,
    "status": "IN_PROGRESS",
    "userTurnCount": 0,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J"
}
```

#### 7.3.2. Submit custom conversation turn

`POST /api/custom-speaking-conversations/{id}/turn`

Request:

```json
{
    "transcript": "I think the biggest change is that students can learn anytime, not only in classrooms.",
    "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
    "timeSpentSeconds": 22,
    "speechAnalytics": {
        "wordCount": 15,
        "wordsPerMinute": 112.5,
        "pauseCount": 2,
        "avgPauseDurationMs": 720,
        "longPauseCount": 0,
        "fillerWordCount": 1,
        "fillerWords": ["um"],
        "avgWordConfidence": 0.91,
        "lowConfidenceWords": ["classrooms"],
        "wordDetails": []
    }
}
```

Raw response khi conversation tiếp tục:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "title": "Learning With Technology",
        "turnNumber": 2,
        "aiMessage": "That makes sense, especially for people with busy schedules. Do you think online learning can fully replace face-to-face classes, or should they work together?",
        "conversationComplete": false,
        "gradingEnabled": true,
        "status": "IN_PROGRESS",
        "userTurnCount": 1,
        "maxUserTurns": 100,
        "voiceName": "US_NEURAL_J"
    }
}
```

After unwrap:

```json
{
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 2,
    "aiMessage": "That makes sense, especially for people with busy schedules. Do you think online learning can fully replace face-to-face classes, or should they work together?",
    "conversationComplete": false,
    "gradingEnabled": true,
    "status": "IN_PROGRESS",
    "userTurnCount": 1,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J"
}
```

Raw response khi conversation complete do max turn:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "title": "Learning With Technology",
        "turnNumber": 100,
        "aiMessage": null,
        "conversationComplete": true,
        "gradingEnabled": true,
        "status": "COMPLETED",
        "userTurnCount": 100,
        "maxUserTurns": 100,
        "voiceName": "US_NEURAL_J"
    }
}
```

After unwrap:

```json
{
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 100,
    "aiMessage": null,
    "conversationComplete": true,
    "gradingEnabled": true,
    "status": "COMPLETED",
    "userTurnCount": 100,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J"
}
```

#### 7.3.3. Finish custom conversation

`POST /api/custom-speaking-conversations/{id}/finish`

Request body:

```json
null
```

Raw response:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "title": "Learning With Technology",
        "turnNumber": 6,
        "aiMessage": null,
        "conversationComplete": true,
        "gradingEnabled": true,
        "status": "COMPLETED",
        "userTurnCount": 5,
        "maxUserTurns": 100,
        "voiceName": "US_NEURAL_J"
    }
}
```

After unwrap:

```json
{
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 6,
    "aiMessage": null,
    "conversationComplete": true,
    "gradingEnabled": true,
    "status": "COMPLETED",
    "userTurnCount": 5,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J"
}
```

#### 7.3.4. Get custom conversation detail

`GET /api/custom-speaking-conversations/{id}`

Raw response:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "id": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "title": "Learning With Technology",
        "topic": "How technology changes the way people learn",
        "style": "PROFESSIONAL",
        "personality": "PATIENT",
        "expertise": "EDUCATION",
        "voiceName": "US_NEURAL_J",
        "gradingEnabled": true,
        "status": "GRADED",
        "maxUserTurns": 100,
        "userTurnCount": 5,
        "totalTurns": 6,
        "timeSpentSeconds": 118,
        "fluencyScore": 7.0,
        "vocabularyScore": 6.5,
        "coherenceScore": 7.0,
        "pronunciationScore": 7.0,
        "overallScore": 7.0,
        "aiFeedback": "Markdown feedback from AI",
        "startedAt": "2026-03-20 15:21:10",
        "completedAt": "2026-03-20 15:24:30",
        "gradedAt": "2026-03-20 15:24:38",
        "turns": [
            {
                "id": "06e4f55a-55ef-4f6b-ac4f-d8adcd4b9f77",
                "turnNumber": 1,
                "aiMessage": "Technology has changed learning in many interesting ways. From your point of view, what is the biggest change it has made for students?",
                "userTranscript": "I think the biggest change is that students can learn anytime.",
                "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
                "timeSpentSeconds": 22,
                "speechAnalytics": {
                    "wordCount": 11,
                    "wordsPerMinute": 109.0,
                    "pauseCount": 1,
                    "avgPauseDurationMs": 640,
                    "longPauseCount": 0,
                    "fillerWordCount": 0,
                    "avgWordConfidence": 0.92,
                    "fillerWords": [],
                    "lowConfidenceWords": [],
                    "wordDetails": []
                },
                "createdAt": "2026-03-20 15:21:10"
            }
        ]
    }
}
```

After unwrap:

```json
{
    "id": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "topic": "How technology changes the way people learn",
    "style": "PROFESSIONAL",
    "personality": "PATIENT",
    "expertise": "EDUCATION",
    "voiceName": "US_NEURAL_J",
    "gradingEnabled": true,
    "status": "GRADED",
    "maxUserTurns": 100,
    "userTurnCount": 5,
    "totalTurns": 6,
    "timeSpentSeconds": 118,
    "fluencyScore": 7.0,
    "vocabularyScore": 6.5,
    "coherenceScore": 7.0,
    "pronunciationScore": 7.0,
    "overallScore": 7.0,
    "aiFeedback": "Markdown feedback from AI",
    "startedAt": "2026-03-20 15:21:10",
    "completedAt": "2026-03-20 15:24:30",
    "gradedAt": "2026-03-20 15:24:38",
    "turns": [
        {
            "id": "06e4f55a-55ef-4f6b-ac4f-d8adcd4b9f77",
            "turnNumber": 1,
            "aiMessage": "Technology has changed learning in many interesting ways. From your point of view, what is the biggest change it has made for students?",
            "userTranscript": "I think the biggest change is that students can learn anytime.",
            "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
            "timeSpentSeconds": 22,
            "speechAnalytics": {
                "wordCount": 11,
                "wordsPerMinute": 109.0,
                "pauseCount": 1,
                "avgPauseDurationMs": 640,
                "longPauseCount": 0,
                "fillerWordCount": 0,
                "avgWordConfidence": 0.92,
                "fillerWords": [],
                "lowConfidenceWords": [],
                "wordDetails": []
            },
            "createdAt": "2026-03-20 15:21:10"
        }
    ]
}
```

#### 7.3.5. Get custom conversation history

`GET /api/custom-speaking-conversations?page=0&size=10`

Raw response:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "page": 0,
        "size": 10,
        "totalElements": 1,
        "totalPages": 1,
        "items": [
            {
                "id": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
                "title": "Learning With Technology",
                "topic": "How technology changes the way people learn",
                "style": "PROFESSIONAL",
                "personality": "PATIENT",
                "expertise": "EDUCATION",
                "voiceName": "US_NEURAL_J",
                "gradingEnabled": true,
                "status": "GRADED",
                "maxUserTurns": 100,
                "userTurnCount": 5,
                "totalTurns": 6,
                "timeSpentSeconds": 118,
                "fluencyScore": 7.0,
                "vocabularyScore": 6.5,
                "coherenceScore": 7.0,
                "pronunciationScore": 7.0,
                "overallScore": 7.0,
                "aiFeedback": "Markdown feedback from AI",
                "startedAt": "2026-03-20 15:21:10",
                "completedAt": "2026-03-20 15:24:30",
                "gradedAt": "2026-03-20 15:24:38",
                "turns": null
            }
        ]
    }
}
```

After unwrap:

```json
{
    "page": 0,
    "size": 10,
    "totalElements": 1,
    "totalPages": 1,
    "items": [
        {
            "id": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
            "title": "Learning With Technology",
            "topic": "How technology changes the way people learn",
            "style": "PROFESSIONAL",
            "personality": "PATIENT",
            "expertise": "EDUCATION",
            "voiceName": "US_NEURAL_J",
            "gradingEnabled": true,
            "status": "GRADED",
            "maxUserTurns": 100,
            "userTurnCount": 5,
            "totalTurns": 6,
            "timeSpentSeconds": 118,
            "fluencyScore": 7.0,
            "vocabularyScore": 6.5,
            "coherenceScore": 7.0,
            "pronunciationScore": 7.0,
            "overallScore": 7.0,
            "aiFeedback": "Markdown feedback from AI",
            "startedAt": "2026-03-20 15:21:10",
            "completedAt": "2026-03-20 15:24:30",
            "gradedAt": "2026-03-20 15:24:38",
            "turns": null
        }
    ]
}
```

#### 7.3.6. Get custom conversation completion snapshot

`GET /api/user/results/custom-conversations/{conversationId}/completion-snapshot`

Raw response:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "module": "SPEAKING",
        "referenceType": "CUSTOM_SPEAKING_CONVERSATION",
        "referenceId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
        "completionTitle": "Bạn vừa hoàn thành custom conversation: Learning With Technology",
        "primaryScoreLabel": "Overall score",
        "primaryScore": 7.0,
        "primaryScoreDisplay": "7.0",
        "xpEarned": 15,
        "streakKept": true,
        "todayGoalProgress": {
            "targetMinutes": 30,
            "studiedMinutes": 18,
            "percentage": 60
        },
        "scoreSummary": [],
        "deltas": [],
        "improvements": [],
        "nextAction": null,
        "secondaryAction": null,
        "metadata": {
            "module": "SPEAKING",
            "referenceType": "CUSTOM_SPEAKING_CONVERSATION"
        }
    }
}
```

After unwrap:

```json
{
    "module": "SPEAKING",
    "referenceType": "CUSTOM_SPEAKING_CONVERSATION",
    "referenceId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "completionTitle": "Bạn vừa hoàn thành custom conversation: Learning With Technology",
    "primaryScoreLabel": "Overall score",
    "primaryScore": 7.0,
    "primaryScoreDisplay": "7.0",
    "xpEarned": 15,
    "streakKept": true,
    "todayGoalProgress": {
        "targetMinutes": 30,
        "studiedMinutes": 18,
        "percentage": 60
    },
    "scoreSummary": [],
    "deltas": [],
    "improvements": [],
    "nextAction": null,
    "secondaryAction": null,
    "metadata": {
        "module": "SPEAKING",
        "referenceType": "CUSTOM_SPEAKING_CONVERSATION"
    }
}
```

Ghi chú:

- shape chính xác của `CompletionSnapshot` nên coi `docs/result-journey-reminder-api-fe-handoff.md` là source of truth
- ví dụ trên chỉ là skeleton tối thiểu cho phase 7A

### 7.4. Custom Conversation STOMP Contracts

#### 7.4.1. Connect

Handshake:

```text
/ws/realtime-chat
```

STOMP `CONNECT` header:

```text
Authorization: Bearer <access_token>
```

Subscribe:

```text
/topic/custom-speaking-conversation/{userId}
```

Publish destination:

```text
/app/custom-speaking-conversation
```

#### 7.4.2. Action `start`

Request:

```json
{
    "action": "start",
    "topic": "How technology changes the way people learn",
    "style": "PROFESSIONAL",
    "personality": "PATIENT",
    "expertise": "EDUCATION",
    "gradingEnabled": true,
    "voiceName": "US_NEURAL_J"
}
```

#### 7.4.3. Action `submit`

Request:

```json
{
    "action": "submit",
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "transcript": "I think the biggest change is that students can learn anytime, not only in classrooms.",
    "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
    "timeSpentSeconds": 22,
    "speechAnalytics": {
        "wordCount": 15,
        "wordsPerMinute": 112.5,
        "pauseCount": 2,
        "avgPauseDurationMs": 720,
        "longPauseCount": 0,
        "fillerWordCount": 1,
        "fillerWords": ["um"],
        "avgWordConfidence": 0.91,
        "lowConfidenceWords": ["classrooms"],
        "wordDetails": []
    }
}
```

#### 7.4.4. Action `finish`

Request:

```json
{
    "action": "finish",
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f"
}
```

#### 7.4.5. WS response `AI_MESSAGE`

Response:

```json
{
    "type": "AI_MESSAGE",
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 2,
    "aiMessage": "That makes sense, especially for people with busy schedules. Do you think online learning can fully replace face-to-face classes, or should they work together?",
    "audioBase64": "BASE64_MP3_OR_AUDIO_BYTES",
    "status": "IN_PROGRESS",
    "userTurnCount": 1,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J",
    "errorMessage": null,
    "timestamp": "2026-03-20 15:22:01"
}
```

#### 7.4.6. WS response `CONVERSATION_COMPLETE`

Response:

```json
{
    "type": "CONVERSATION_COMPLETE",
    "conversationId": "3a76a53c-18a9-46e3-9b84-1554a1e6fd4f",
    "title": "Learning With Technology",
    "turnNumber": 6,
    "aiMessage": null,
    "audioBase64": null,
    "status": "COMPLETED",
    "userTurnCount": 5,
    "maxUserTurns": 100,
    "voiceName": "US_NEURAL_J",
    "errorMessage": null,
    "timestamp": "2026-03-20 15:24:30"
}
```

#### 7.4.7. WS response `ERROR`

Response:

```json
{
    "type": "ERROR",
    "conversationId": null,
    "title": null,
    "turnNumber": null,
    "aiMessage": null,
    "audioBase64": null,
    "status": null,
    "userTurnCount": null,
    "maxUserTurns": null,
    "voiceName": null,
    "errorMessage": "Conversation not found: ...",
    "timestamp": "2026-03-20 15:24:30"
}
```

### 7.5. Guided Conversation Contracts

Phần này hiện chưa có tài liệu backend riêng trong repo. Contract bên dưới là:

- `implementation-observed`
- suy ra từ `src/pages/speaking/SpeakingConversationPage.jsx`
- suy ra từ `src/pages/speaking/SpeakingConversationResultPage.jsx`
- suy ra từ `src/pages/speaking/SpeakingConversationHistoryPage.jsx`

Mobile nên dùng section này như `working contract`, nhưng cần confirm backend trước khi khóa model.

#### 7.5.1. Start guided conversation qua STOMP

Publish destination:

```text
/app/speaking-conversation
```

Request:

```json
{
    "action": "start",
    "topicId": "6a4bb4c8-6e2a-4ef6-a767-52ec1d2b4631"
}
```

Inferred response khi AI hỏi câu đầu:

```json
{
    "conversationId": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
    "aiQuestion": "Let us start with a simple question. What do you usually do on weekends?",
    "audioBase64": "BASE64_MP3_OR_AUDIO_BYTES",
    "turnType": "QUESTION",
    "lastTurn": false,
    "conversationComplete": false,
    "type": "AI_MESSAGE"
}
```

#### 7.5.2. Submit guided conversation turn qua REST

`POST /api/speaking/conversations/{conversationId}/turn`

Request:

```json
{
    "transcript": "I usually spend time with my family and sometimes go to a cafe with friends.",
    "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
    "timeSpentSeconds": 26,
    "speechAnalytics": {
        "wordCount": 15,
        "wordsPerMinute": 112.5,
        "pauseCount": 2,
        "avgPauseDurationMs": 720,
        "longPauseCount": 0,
        "fillerWordCount": 1,
        "fillerWords": ["um"],
        "avgWordConfidence": 0.91,
        "lowConfidenceWords": ["family"],
        "wordDetails": []
    }
}
```

Inferred response khi conversation tiếp tục:

```json
{
    "conversationId": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
    "aiQuestion": "Why do you think weekends are important for students or workers?",
    "audioBase64": "BASE64_MP3_OR_AUDIO_BYTES",
    "turnType": "QUESTION",
    "lastTurn": false,
    "conversationComplete": false
}
```

Inferred response khi backend gửi hint:

```json
{
    "conversationId": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
    "aiQuestion": "You can mention rest, family time, or personal hobbies.",
    "audioBase64": null,
    "turnType": "HINT",
    "lastTurn": false,
    "conversationComplete": false
}
```

Inferred response khi complete:

```json
{
    "conversationId": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
    "aiQuestion": null,
    "audioBase64": null,
    "turnType": "QUESTION",
    "lastTurn": true,
    "conversationComplete": true,
    "type": "CONVERSATION_COMPLETE"
}
```

#### 7.5.3. Guided conversation detail

`GET /api/speaking/conversations/{conversationId}`

Inferred after unwrap:

```json
{
    "id": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
    "topicId": "6a4bb4c8-6e2a-4ef6-a767-52ec1d2b4631",
    "topicQuestion": "Describe your weekend routine",
    "topicPart": "PART_1",
    "status": "GRADED",
    "overallBandScore": 6.5,
    "fluencyScore": 6.5,
    "lexicalScore": 6.0,
    "grammarScore": 6.5,
    "pronunciationScore": 7.0,
    "aiFeedback": "Markdown feedback from AI",
    "startedAt": "2026-03-20 15:21:10",
    "completedAt": "2026-03-20 15:24:30",
    "gradedAt": "2026-03-20 15:24:38",
    "totalTurns": 6,
    "turns": [
        {
            "id": "turn-1",
            "turnNumber": 1,
            "aiQuestion": "What do you usually do on weekends?",
            "userTranscript": "I usually spend time with my family.",
            "audioUrl": "https://cdn.example.com/audio/turn-1.mp3",
            "timeSpentSeconds": 22,
            "speechAnalytics": {
                "wordCount": 8,
                "wordsPerMinute": 98.0,
                "pauseCount": 1,
                "avgPauseDurationMs": 640,
                "longPauseCount": 0,
                "fillerWordCount": 0,
                "avgWordConfidence": 0.92,
                "fillerWords": [],
                "lowConfidenceWords": [],
                "wordDetails": []
            },
            "createdAt": "2026-03-20 15:21:10"
        }
    ]
}
```

#### 7.5.4. Guided conversation history

`GET /api/speaking/conversations?page=0&size=10`

Inferred after unwrap:

```json
{
    "page": 0,
    "size": 10,
    "totalElements": 1,
    "totalPages": 1,
    "items": [
        {
            "id": "77d3c76a-8de8-4b39-b041-0f6c1d3b7a20",
            "topicQuestion": "Describe your weekend routine",
            "topicPart": "PART_1",
            "status": "GRADED",
            "overallBandScore": 6.5,
            "totalTurns": 6,
            "startedAt": "2026-03-20 15:21:10"
        }
    ]
}
```

#### 7.5.5. Guided conversation result readiness

Guided result page hiện giả định:

- polling `GET /api/speaking/conversations/{id}` mỗi vài giây
- dừng khi status là `GRADED` hoặc `FAILED`

Nghĩa là mobile model cho guided detail phải chấp nhận cả giai đoạn:

- chưa có score
- đang grading
- đã graded

### 7.6. STT Raw WebSocket Contract

Phần này cũng là `implementation-observed` từ `src/hooks/useWsSpeechRecording.js`.

#### 7.6.1. Connect

Endpoint:

```text
/ws/speaking/stt?token=<access_token>
```

Client gửi:

- binary PCM chunks 16kHz Int16
- 1 message JSON khi stop:

```json
{
    "type": "finish"
}
```

#### 7.6.2. Event `ready`

Server có thể gửi:

```json
{
    "type": "ready"
}
```

FE hiện chỉ dùng event này cho debug.

#### 7.6.3. Event `transcript`

Server gửi partial hoặc final transcript:

```json
{
    "type": "transcript",
    "text": "I usually spend time with my family",
    "final": false
}
```

Hoặc:

```json
{
    "type": "transcript",
    "text": "I usually spend time with my family",
    "final": true
}
```

Rule render:

- `final = false`: replace phần transcript tạm thời hiện tại
- `final = true`: append vào transcript tích lũy

#### 7.6.4. Event `speech_summary`

Server gửi summary cuối để FE normalize thành payload submit:

```json
{
    "type": "speech_summary",
    "wordCount": 15,
    "wordsPerMinute": 112.5,
    "pauseCount": 2,
    "avgPauseDurationMs": 720,
    "longPauseCount": 0,
    "fillerWordCount": 1,
    "fillerWords": ["um"],
    "avgWordConfidence": 0.91,
    "lowConfidenceWords": ["classrooms"],
    "wordDetails": []
}
```

Web hiện còn tolerate các biến thể key sau:

- `wpm` thay cho `wordsPerMinute`
- `words` thay cho `wordDetails`

#### 7.6.5. Event `error`

Server gửi:

```json
{
    "type": "error",
    "message": "Speech recognition failed"
}
```

FE hiện:

- hiển thị warning
- không block manual transcript fallback

### 7.7. Error Contract Notes

Với REST:

- wrapper failure có thể là `{ success: false, message, data }`
- web network layer map lỗi về `ApiError`

Với STOMP custom/guided:

- app cần handle `type = ERROR`
- không assume mọi failure đều đến dưới dạng disconnect

Với STT:

- lỗi socket hoặc `type = error` không được chặn user nhập transcript thủ công

## 8. Kiến Trúc Flutter Đề Xuất Cho Phase 7A

Vì layout cơ bản đã có, phase này nên tập trung vào 3 lớp:

```txt
lib/
  core/
    speaking/
      speech_analytics_models.dart
      speaking_stt_client.dart
      ai_voice_playback_service.dart
    custom_speaking/
      custom_speaking_api.dart
      custom_speaking_models.dart
      custom_speaking_ws_client.dart
      custom_conversation_snapshot_store.dart
  features/
    custom_speaking/
      application/
        custom_speaking_setup_controller.dart
        custom_speaking_chat_controller.dart
      presentation/
        custom_speaking_page.dart
        custom_speaking_chat_page.dart
        widgets/
          conversation_message_list.dart
          conversation_recorder_panel.dart
          conversation_status_bar.dart
```

Nguyên tắc:

- layout page không nên chứa logic socket, recorder và snapshot
- controller phải expose state đã ready-to-render
- recorder/STT là shared service, không embed thẳng trong page
- custom snapshot store phải độc lập để sau này guided flow có thể bỏ qua mà không ảnh hưởng shared chat shell

## 9. State Contract Nên Có Trên Mobile

Controller state tối thiểu nên chứa:

```dart
class CustomSpeakingChatState {
  final bool loading;
  final bool isConnected;
  final bool isWaiting;
  final bool isSubmitting;
  final bool isSpeaking;
  final bool recording;
  final bool sttSupported;
  final String transcript;
  final Duration timer;
  final CustomConversationSummary? conversation;
  final List<ConversationMessageItem> messages;
  final SpeechAnalyticsSummary? latestSpeechSummary;
}
```

`ConversationMessageItem` nên đủ generic để reuse:

```dart
class ConversationMessageItem {
  final String id;
  final ConversationRole role; // ai | user | system
  final String text;
  final String? turnType; // QUESTION | HINT | ...
  final SpeechAnalyticsPayload? speechAnalytics;
}
```

Snapshot local cho custom flow nên giữ:

- `conversationId`
- `title`
- `topic`
- `latestAiMessage`
- `gradingEnabled`
- `status`
- `userTurnCount`
- `maxUserTurns`
- `voiceName`
- `updatedAt`

## 10. State Machine Cần Implement

### 10.1. Page lifecycle

`idle -> loading -> ready -> locked -> redirecting`

### 10.2. Chat interaction lifecycle

`ready -> recording -> awaiting_ai -> ready`

hoặc:

`ready -> finishing -> completed_redirect`

### 10.3. Locked statuses

`COMPLETED`, `GRADING`, `GRADED`, `FAILED`

Khi ở locked state:

- không cho start recording
- không cho submit transcript
- không cho finish lần nữa
- CTA chính là mở result

## 11. Delivery Slices Đề Xuất

### 11.1. Slice A - Shared data và infra

- models cho conversation detail, realtime event, message item, speech analytics
- REST client cho custom conversation
- STOMP client cho custom conversation
- snapshot store local
- recorder/STT abstraction

### 11.2. Slice B - Setup và bootstrap

- bind form start conversation
- REST start
- save snapshot
- route sang chat với bootstrap
- load detail khi chat page mở

### 11.3. Slice C - Active chat loop

- message list render từ detail
- recorder hoặc manual transcript fallback
- optimistic user bubble
- STOMP submit với REST fallback
- AI reply append
- auto-scroll
- replay và auto-play prompt

### 11.4. Slice D - Finish, lock và result handoff

- finish conversation
- clear snapshot khi complete
- locked banner
- navigate đúng sang result
- reopen active conversation từ history route

### 11.5. Slice E - Guided reuse prep

- shared chat shell không custom-specific
- message model có `turnType`
- controller boundary tách để guided flow nối vào sau này

## 12. Acceptance Criteria

Phase 7A được xem là xong khi:

1. user có thể start custom speaking conversation từ mobile
2. page chat load đúng bằng `conversationId` và không phụ thuộc hoàn toàn vào route bootstrap
3. user có thể gửi turn bằng transcript, kể cả khi live STT không sẵn
4. app ưu tiên WS cho custom turn nhưng vẫn chạy nếu phải fallback sang REST
5. prompt AI mới được append và có thể replay
6. app resume được conversation đang `IN_PROGRESS` sau khi vào lại route
7. app không cho gửi thêm turn khi conversation đã locked
8. finish flow đưa user sang result route đúng
9. local snapshot được clear khi conversation complete
10. architecture sau phase 7A không chặn guided conversation reuse ở slice sau

## 13. QA Checklist Nên Chạy

- start conversation bình thường với grading bật
- start conversation với grading tắt
- submit turn khi WS đang connected
- submit turn khi WS publish fail để verify REST fallback
- finish conversation khi đang recording
- mở lại conversation đang dang dở từ history hoặc deep link
- mở lại conversation đã `COMPLETED` để verify locked banner
- case STT không khả dụng nhưng vẫn gửi transcript được
- case AI trả `audioBase64`
- case app chỉ có local TTS fallback

## 14. Rủi Ro Và Quyết Định Cần Chốt Trước Khi Code

### 14.1. `voiceName` và enum options

Phải xác nhận backend thực tế có support:

- `voiceName`
- tập enum mở rộng ngoài doc hiện tại

Nếu chưa chốt:

- mobile chỉ dùng tập option tối thiểu
- đừng hard-code full set theo web utils ngay

### 14.2. Flutter STOMP stack

Nếu STOMP trên Flutter gặp friction về reconnect hoặc auth:

- vẫn có thể ship custom chat bằng REST-first cho detail/start
- chỉ giữ WS cho submit/finish khi stack đủ ổn
- tuyệt đối không để feature bị chặn hoàn toàn vì realtime

### 14.3. Live STT không nên là blocker của phase

Web đang có `useWsSpeechRecording`, nhưng mobile không nên phụ thuộc 100% vào parity STT ngay lập tức.

An toàn nhất cho 7A là:

- có transcript fallback từ ngày đầu
- live STT là enhancement, không phải điều kiện để chat hoạt động

### 14.4. Guided conversation parity

Guided conversation có thể reuse nhiều thứ từ custom chat, nhưng route semantics khác.

Do đó:

- đừng nhồi cả guided orchestration vào custom controller
- chỉ reuse shared message/recorder/audio pieces

## 15. Kết Luận

Phase 7A không phải phase dựng thêm một màn đẹp hơn. Nó là phase làm cho màn chat speaking trên mobile hoạt động thật và chịu được các tình huống thực tế như reconnect, resume, finish, locked-state và result handoff.

Lựa chọn hợp lý nhất là:

- lấy `custom speaking conversation` làm trọng tâm ship trước
- giữ shared abstractions đủ sạch để guided conversation nối vào sau
- không block phase vì audio upload, advanced voice polish hoặc enum expansion chưa chốt

Nếu làm đúng, phase 7A sẽ biến speaking chat từ `layout demo` thành `conversation loop thật` trên mobile.
