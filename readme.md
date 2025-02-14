# Quoridouble

강화학습 기반 AI와 PvP 대전, 개선된 UX가 구현된 Quoridor 게임 앱

<br />

**Application** `(출시 이후 내부 정책에 따라 소스코드 비공개)`<br />
<img src="https://img.shields.io/badge/Flutter-181717?style=flat-square&logo=flutter" />
<img src="https://img.shields.io/badge/Socket.IO Client-181717?style=flat-square&logo=Socket.io" />
<img src="https://img.shields.io/badge/Dart-181717?style=flat-square&logo=Dart" /> <br />

**Back-end** [`@release/be`](https://github.com/KibleLab/quoridouble/tree/@release/be) <br />
<img src="https://img.shields.io/badge/Spring Boot-181717?style=flat-square&logo=springboot" />
<img src="https://img.shields.io/badge/Socket.IO-181717?style=flat-square&logo=Socket.io" />
<img src="https://img.shields.io/badge/Gradle-181717?style=flat-square&logo=gradle" />
<img src="https://img.shields.io/badge/Java-181717?style=flat-square&logo=java" />

**RL Engine** [`@release/rl-engine`](https://github.com/KibleLab/quoridouble/tree/@release/rl-engine) <br />
<img src="https://img.shields.io/badge/CMake-181717?style=flat-square&logo=cmake" />
<img src="https://img.shields.io/badge/C++-181717?style=flat-square&logo=cplusplus" />

<br />

**앱 다운로드:** <br />
[<img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200" />](https://play.google.com/store/apps/details?id=xyz.quoridouble)

<br />

## Overview

### 프로젝트명

Quoridouble - 강화학습 기반 AI와 PvP 대전, 개선된 UX가 구현된 Quoridor 게임 앱

### 제작기간

2024.08 ~ (진행중)

### 팀원 및 역할

<table border="1">
  <tr>
      <td align="center"><a href="https://github.com/Vulpes94"><img height="100px" width="100px" src="https://avatars.githubusercontent.com/u/74402423?v=4" alt="김준기 GitHub"/></a></td>
			<td align="left">김준기 (팀장)</br>Application, RL, 선행 연구</td>
  </tr>
  <tr>
			<td align="center"><a href="https://github.com/RegistryHJ"><img height="100px" width="100px" src="https://avatars.githubusercontent.com/u/55695897?v=4" alt="이현준 GitHub"/></a></td>
      <td align="left">이현준 (팀원)</br>Back-end, UI/UX 설계, 문서화</td>  
  </tr>
	<tr>
		<td align="center"><a href="https://github.com/SDpardres"><img height="100px" width="100px" src="https://avatars.githubusercontent.com/u/143976588?v=4" alt="최호연 GitHub"/></a></td>
		<td align="left">최호연 (팀원)</br>Back-end, QA</td>
	</tr>
</table>

<br />

## Background

### 현황

- 팀원들이 전략적 보드게임(체스, 오목, Quoridor)을 즐김
- 체스, 오목은 다양한 모바일 앱이 시장에 존재
- Quoridor는 상대적으로 인지도가 낮음

### 기존 Quoridor 앱의 문제점

- 출시된 앱의 수가 매우 적음
- 조작감 등 UX가 좋지 않음
- AI와 PvP(Player vs Player) 기능이 하나의 앱에 동시에 탑재가 되어 있지 않음

### 개선 목표

- RL Game Agent 구현
- PvP 기능 구현
- 사용자 경험(UX) 개선

<br>

## Timeline

### 선행 연구 (8월)

- Depth Limited Alpha-Beta Pruning 알고리즘을 활용한 5✕5 Mini 버전 ProtoType 개발 (Python 구현)
- RL Game Agent의 기본 로직 확립
- UI/UX 설계

### Application 개발 (9~10월)

- Flutter를 사용하여 Cross Platform Application 개발
- RL Game Agent를 Dart 언어로 포팅
- UI/UX 구현 및 AI 2-way Game 구현

### 최적화 연구 (10월)

- Quoridor AI 에이전트 성능 향상을 위한 길찾기 알고리즘 비교 연구 (한국실천공학교육학회, 2024)
- 프로그래밍 언어별 성능 분석

### Back-end 구현 (11월)

- Socket.IO 기반의 BE-Application 간 실시간 통신 구현(실시간 PvP 2-way Game)

### Android 출시 전 작업 (12월)

- PvP 기능 일시적 제거 (AI 선출시 목표)
- Application 리펙토링 및 최적화
- Google AdMob 추가
- 출시를 위한 Android Native 작업

### RL Game Agent 재설계 및 구현 (12월~)

- Monte-Carlo Tree Search 알고리즘 기반으로 재설계
- Back-end와 Shared Library 기반으로 결합

### Android 출시 작업 (1월)

- Google Play Console에서 내부/비공개 테스트
- 사전 출시 보고서를 기반으로 출시를 위한 코드 최적화

### Android 출시 (2월)

- Google Play에 정식 출시
- 사용자 피드백을 바탕으로 UI/UX 개선

<br />

## Study for Optimization

> **[Quoridor-Pathfind](https://github.com/RegistryHJ/quoridor-pathfind)** <br />
> Quoridor AI 강화학습 에이전트의 성능 향상을 위한 길찾기 알고리즘 비교 연구 <br />
> 2024 교육장비개발 및 아이디어 경진대회 교육장비개발 부문 동상 (한국실천공학교육학회) <br />
> 한국실천공학교육학회 2024 종합학술발표대회 논문집 교육장비개발 부문 논문 게재 (PP. 243~244) <br />

<br />

## <br />

Copyright © 2024 KibleLab
