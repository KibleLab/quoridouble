use std::collections::HashSet;
use std::fmt;
use rand::Rng;
use rand::seq::SliceRandom;

use grid_pathfinding::PathingGrid;
use grid_util::grid::Grid;
use grid_util::point::Point;

#[derive(Clone)]
struct State {
    pieces: Vec<i32>,
    enemy_pieces: Vec<i32>,
    depth: i32,
}

impl State {
    fn new() -> Self {
        let mut pieces = vec![0; 289];
        let mut enemy_pieces = vec![0; 289];
        pieces[280] = 1;
        enemy_pieces[280] = 1;
        State {
            pieces,
            enemy_pieces,
            depth: 0,
        }
    }

    fn user1_pos(&self, is_first: i32) -> (usize, usize) {
        let player = if self.depth % 2 == is_first {
            &self.pieces
        } else {
            &self.enemy_pieces
        };
        let pos = player.iter().position(|&x| x == 1).unwrap();
        
        (pos / 17 / 2, pos % 17 / 2)
    }

    fn user2_pos(&self, is_first: i32) -> (usize, usize) {
        let player = if self.depth % 2 == is_first {
            self.enemy_pieces.iter().rev().cloned().collect()
        } else {
            self.pieces.iter().rev().cloned().collect()
        };
        let pos = player.iter().position(|&x| x == 1).unwrap();
        
        (pos / 17 / 2, pos % 17 / 2)
    }

    fn is_current_turn(&self, is_first: i32) -> bool {
        self.depth % 2 == is_first
    }

    fn get_user1_wall_count(&self, is_first: i32) -> i32 {
        let player = if self.depth % 2 == is_first {
            &self.pieces
        } else {
            &self.enemy_pieces
        };
        10 - (player.iter().filter(|&&p| p == 2).count() as i32 / 3)
    }

    fn get_user2_wall_count(&self, is_first: i32) -> i32 {
        let player = if self.depth % 2 == is_first {
            &self.enemy_pieces
        } else {
            &self.pieces
        };
        10 - (player.iter().filter(|&&p| p == 2).count() as i32 / 3)
    }


    fn convert_xy(&self, x: i32, y: i32) -> usize {
        (x * 17 + y) as usize
    }

    fn convert_board(&self) -> Vec<Vec<i32>> {
        let mut board = vec![vec![0; 17]; 17];
        let wall = -1;

        for x in 0..17 {
            for y in 0..17 {
                let index = self.convert_xy(x, y);
                let piece = self.pieces[index];
                let enemy_piece = self.enemy_pieces[288 - index];

                board[x as usize][y as usize] = match (piece, enemy_piece) {
                    (1, _) => 1,
                    (_, 1) => 2,
                    (2, _) | (_, 2) => wall,
                    _ => 0,
                };
            }
        }

        board
    }

    fn xy_to_wall_action(&self, x: i32, y: i32) -> usize {
        if x % 2 == 0 && y % 2 == 1 {
            ((x / 2) + 1 + 8 * ((y - 1) / 2) + 11) as usize
        } else if x % 2 == 1 && y % 2 == 0 {
            ((y / 2) + 1 + 8 * ((x - 1) / 2) + 11 + 64) as usize
        } else {
            panic!("Invalid coordinates for wall action: x={}, y={}", x, y);
        }
    }

    fn is_lose(&self) -> bool {
        (0..17).step_by(2).any(|line| {
            self.enemy_pieces.get(line).map_or(false, |&piece| piece == 1)
        })
    }
    
    fn is_draw(&self) -> bool {
        self.depth >= 200
    }

    fn is_done(&self) -> bool {
        self.is_lose() || self.is_draw()
    }

    fn is_first_player(&self) -> bool {
        self.depth % 2 == 0
    }


    fn is_wall(&self, x: i32, y: i32) -> bool {
        let index = self.convert_xy(x, y);
        let piece = self.pieces[index];
        let enemy_piece = self.enemy_pieces[288 - index];
        piece == 2 || enemy_piece == 2
    }

    fn is_invalid_position(&self, x: i32, y: i32) -> bool {
        x < 0 || x >= 17 || y < 0 || y >= 17 || self.is_wall(x, y)
    }

    // base를 exp만큼 거듭제곱하는 함수
    fn pow(&self, base: i32, exp: u32) -> i32 {
        base.pow(exp)  // `i32::pow` 메서드를 사용
    }

    fn legal_move(&self) -> Vec<(i32, i32)> {
        let p1_index = self.pieces.iter().position(|&x| x == 1).unwrap();
        let p1_pos = [(p1_index / 17) as i32, (p1_index % 17) as i32];

        let p2_index = self.enemy_pieces.iter().position(|&x| x == 1).unwrap();
        let reverse = 288 - p2_index;
        let p2_pos = [(reverse / 17) as i32, (reverse % 17) as i32];

        let mut dxy = vec![(0, 2), (0, -2), (-2, 0), (2, 0)];

        dxy.retain(|&(dx, dy)| {
            let new_x = p1_pos[0] + dx / 2;
            let new_y = p1_pos[1] + dy / 2;
            !self.is_invalid_position(new_x, new_y)
        });

        let delta_x = p2_pos[0] - p1_pos[0];
        let delta_y = p2_pos[1] - p1_pos[1];

        if dxy.contains(&(delta_x, delta_y)) {
            dxy.retain(|&move_| move_ != (delta_x, delta_y));

            let check_x = p2_pos[0] + delta_x / 2;
            let check_y = p2_pos[1] + delta_y / 2;

            if !self.is_invalid_position(check_x, check_y) {
                dxy.push((delta_x * 2, delta_y * 2));
            } else {
                let d_x = if delta_x == 0 { -1 } else { 0 };
                let d_y = if delta_y == 0 { -1 } else { 0 };

                for i in 1..3 {
                    let check_x = p2_pos[0] + self.pow(d_x, i);
                    let check_y = p2_pos[1] + self.pow(d_y, i);
                    if !self.is_invalid_position(check_x, check_y) {
                        dxy.push((delta_x + self.pow(d_x, i) * 2, delta_y + self.pow(d_y, i) * 2));
                    }
                }
            }
        }

        dxy
    }

    fn legal_actions(&self) -> Vec<usize> {
        let mut actions = HashSet::new();
        let board = self.convert_board();
        let legal_moves = self.legal_move();

        let moves = vec![
            (-2, 0), (-2, 2), (0, 2), (2, 2), (2, 0), (2, -2), (0, -2), (-2, -2),
            (-4, 0), (0, 4), (4, 0), (0, -4),
        ];

        for target in legal_moves {
            if let Some(index) = moves.iter().position(|&m| m == target) {
                actions.insert(index);
            }
        }

        let wallcount = 10 - self.pieces.iter().filter(|&&x| x == 2).count() / 3;

        if wallcount > 0 {
            for i in (1..board.len()).step_by(2) {
                for j in (1..board[board.len() - 1].len()).step_by(2) {
                    if board[i][j] == 0 {
                        if board[i - 1][j] == 0 && board[i + 1][j] == 0 {
                            if self.is_path_available(&board, i as i32 - 1, j as i32) {
                                actions.insert(self.xy_to_wall_action(i as i32 - 1, j as i32));
                            }
                        }
                        if board[i][j - 1] == 0 && board[i][j + 1] == 0 {
                            if self.is_path_available(&board, i as i32, j as i32 - 1) {
                                actions.insert(self.xy_to_wall_action(i as i32, j as i32 - 1));
                            }
                        }
                    }
                }
            }
        }

        // Convert HashSet to Vec and sort it
        let mut sorted_actions: Vec<_> = actions.into_iter().collect();
        sorted_actions.sort();

        sorted_actions
    }

    fn pruning_action(&self) -> Vec<usize> {
        let legal_actions = self.legal_actions();
    
        // 조건에 맞는 액션을 필터링
        let mut fixed_actions1: Vec<usize> = legal_actions.iter().cloned().filter(|&x| x < 12).collect();
        let fixed_actions2: Vec<usize> = legal_actions.iter().cloned().filter(|&x| x >= 76).collect();
        let mut shuffle_actions: Vec<usize> = legal_actions.iter().cloned().filter(|&x| x >= 12 && x < 76).collect();
    
        // 셔플 작업 수행
        let mut rng = rand::thread_rng();
        shuffle_actions.shuffle(&mut rng);
    
        // 셔플한 액션에서 절반을 선택
        let selected_actions: Vec<usize> = shuffle_actions.iter().cloned().take(shuffle_actions.len() / 2).collect();
    
        // 모든 액션들을 합침
        fixed_actions1.extend(fixed_actions2);
        fixed_actions1.extend(selected_actions);
    
        fixed_actions1  // 최종 액션 목록 반환
    }

    fn is_path_available(&self, board: &Vec<Vec<i32>>, act_x: i32, act_y: i32) -> bool {
        const WALL: i32 = -1;

        // 2D 배열을 복사합니다.
        let mut mat: Vec<Vec<i32>> = self.convert_board().iter().map(|row| row.clone()).collect();

        // 벽 2개를 나란히 세웠을 때 틈새 막기
        for i in (1..mat.len()).step_by(2) {
            for j in (1..mat[0].len()).step_by(2) {
                mat[i][j] = WALL;
            }
        }

        // mat에 벽 설치 해보기
        mat[act_x as usize][act_y as usize] = WALL;

        if act_x % 2 == 0 {
            mat[(act_x as usize) + 2][act_y as usize] = WALL;
        } else {
            mat[act_x as usize][(act_y as usize) + 2] = WALL;
        }

        let p1_idx = self.pieces.iter().position(|&x| x == 1).unwrap();
        let p1_pos = [(p1_idx / 17) as usize, (p1_idx % 17) as usize];

        let p2_idx = self.enemy_pieces.iter().rev().position(|&x| x == 1).unwrap();
        let p2_pos = [(p2_idx / 17) as usize, (p2_idx % 17) as usize];

        // mat에 표시되어 있는 플레이어 제거
        mat[p1_pos[0]][p1_pos[1]] = 0;
        mat[p2_pos[0]][p2_pos[1]] = 0;

       // pathfinding 패키지를 위해 WALL을 true로, 0을 false로 변환
       let grid_data: Vec<Vec<bool>> = mat.into_iter()
       .map(|row| row.into_iter()
           .map(|value| value == WALL)
           .collect())
       .collect();

        let end_array: Vec<usize> = (0..9).map(|i| i * 2).collect();

        let mut p1_path = false;
        let mut p2_path = false;

        // 배열 크기
        let rows = grid_data.len();
        let cols = grid_data[0].len();        

        for &end in &end_array {
            // PathingGrid 초기화
            let mut pathing_grid = PathingGrid::new(rows, cols, false);

            // 그리드 배열을 PathingGrid에 설정
            for (y, row) in grid_data.iter().enumerate() {
                for (x, &value) in row.iter().enumerate() {
                    pathing_grid.set(x as usize, y as usize, value);
                }
            }
            
            // 경로를 찾기 위한 추가 설정
            pathing_grid.generate_components();
            pathing_grid.allow_diagonal_move = false;

            let start = Point::new(p1_pos[1] as i32, p1_pos[0] as i32);
            let end = Point::new(end as i32, 0);

            if pathing_grid.get_path_single_goal(start, end, false).is_some() {
                p1_path = true;
                break;
            }
        }

        // p1이 길을 못 찾으면 종료
        if !p1_path {
            return false;
        }

        for &end in &end_array {
            // PathingGrid 초기화
            let mut pathing_grid = PathingGrid::new(rows, cols, false);

            // 그리드 배열을 PathingGrid에 설정
            for (y, row) in grid_data.iter().enumerate() {
                for (x, &value) in row.iter().enumerate() {
                    pathing_grid.set(x as usize, y as usize, value);
                }
            }
            
            // 경로를 찾기 위한 추가 설정
            pathing_grid.generate_components();
            pathing_grid.allow_diagonal_move = false;

            let start = Point::new(p2_pos[1] as i32, p2_pos[0] as i32);
            let end = Point::new(end as i32, 16);

            if pathing_grid.get_path_single_goal(start, end, false).is_some() {
                p2_path = true;
                break;
            }
        }

        // 길을 막지 않으면 true
        p1_path && p2_path
    }

    fn reward(&self) -> f64 {
        // 2D 배열을 복사합니다.
        let mut mat: Vec<Vec<i32>> = self.convert_board().iter().map(|row| row.clone()).collect();
        const WALL: i32 = -1;
    
        // 플레이어가 이동할 수 없는 교차로 구간 막기
        for i in (1..mat.len()).step_by(2) {
            for j in (1..mat[i].len()).step_by(2) {
                mat[i][j] = WALL;
            }
        }
    
        let p1_idx = self.pieces.iter().position(|&x| x == 1).unwrap();
        let p1_pos = [(p1_idx / 17) as usize, (p1_idx % 17) as usize];

        let p2_idx = self.enemy_pieces.iter().rev().position(|&x| x == 1).unwrap();
        let p2_pos = [(p2_idx / 17) as usize, (p2_idx % 17) as usize];

        // mat에 표시되어 있는 플레이어 제거
        mat[p1_pos[0]][p1_pos[1]] = 0;
        mat[p2_pos[0]][p2_pos[1]] = 0;
    
       // pathfinding 패키지를 위해 WALL을 true로, 0을 false로 변환
       let grid_data: Vec<Vec<bool>> = mat.into_iter()
       .map(|row| row.into_iter()
           .map(|value| value == WALL)
           .collect())
       .collect();
    
        let end_array: Vec<i32> = (0..9).map(|i| i * 2).collect();
        let mut p1_path_len_array = vec![0; 9];
        let mut p2_path_len_array = vec![0; 9];

        // 배열 크기
        let rows = grid_data.len();
        let cols = grid_data[0].len();       
    
        // 각 목표당 걸리는 거리 측정 (p1)
        for (i, &end) in end_array.iter().enumerate() {
            // PathingGrid 초기화
            let mut pathing_grid = PathingGrid::new(rows, cols, false);

            // 그리드 배열을 PathingGrid에 설정
            for (y, row) in grid_data.iter().enumerate() {
                for (x, &value) in row.iter().enumerate() {
                    pathing_grid.set(x as usize, y as usize, value);
                }
            }

            // 경로를 찾기 위한 추가 설정
            pathing_grid.generate_components();
            pathing_grid.allow_diagonal_move = false;

            let start = Point::new(p1_pos[1] as i32, p1_pos[0] as i32);
            let end = Point::new(end as i32, 0);

            let path = match pathing_grid.get_path_single_goal(start, end, false) {
                Some(value) => value, // 정상적인 경로 반환
                None => Vec::new(),   // 경로가 없을 경우 빈 벡터 반환
            };
    
            for k in 1..path.len() {
                let prev = path[k - 1];
                let curr = path[k];
                p1_path_len_array[i] += (curr.x - prev.x).abs() + (curr.y - prev.y).abs();
            }
    
            p1_path_len_array[i] /= 2;
        }
    
        // 각 목표당 걸리는 거리 측정 (p2)
        for (i, &end) in end_array.iter().enumerate() {
            // PathingGrid 초기화
                let mut pathing_grid = PathingGrid::new(rows, cols, false);

                // 그리드 배열을 PathingGrid에 설정
                for (y, row) in grid_data.iter().enumerate() {
                    for (x, &value) in row.iter().enumerate() {
                        pathing_grid.set(x as usize, y as usize, value);
                }
            }
            
            // 경로를 찾기 위한 추가 설정
            pathing_grid.generate_components();
            pathing_grid.allow_diagonal_move = false;

            let start = Point::new(p2_pos[1] as i32, p2_pos[0] as i32);
            let end = Point::new(end as i32, 16);

            let path = match pathing_grid.get_path_single_goal(start, end, false) {
                Some(value) => value, // 정상적인 경로 반환
                None => Vec::new(),   // 경로가 없을 경우 빈 벡터 반환
            };
            
            for k in 1..path.len() {
                let prev = path[k - 1];
                let curr = path[k];
                p2_path_len_array[i] += (curr.x - prev.x).abs() + (curr.y - prev.y).abs();
            }
    
            p2_path_len_array[i] /= 2;
        }
    
        // 0 이하를 제외한 새로운 배열 생성
        let p1_non_zero: Vec<i32> = p1_path_len_array.into_iter().filter(|&x| x > 0).collect();
        let p2_non_zero: Vec<i32> = p2_path_len_array.into_iter().filter(|&x| x > 0).collect();
    
        // 가장 낮은 값 찾기
        let min_p1 = p1_non_zero.iter().cloned().min().unwrap_or(0);
        let min_p2 = p2_non_zero.iter().cloned().min().unwrap_or(0);
    
        // 두 값의 차이 계산
        let difference = min_p2 - min_p1;
    
        difference as f64
    }

    fn next(&self, action: usize) -> State {
        let mut new_state = State {
            pieces: self.pieces.clone(),
            enemy_pieces: self.enemy_pieces.clone(),
            depth: self.depth + 1,
        };

        let player = 1;
        let wall = 2;

        // 플레이어 위치 구하기
        let pos = self.pieces.iter().position(|&p| p == player).unwrap();

        // 방향 정수
        let dxy: [i32; 12] = [-34, -32, 2, 36, 34, 32, -2, -36, -68, 4, 68, -4];

        let mut x: i32;
        let mut y: i32;

        if action >= 0 && action <= 11 {
            new_state.pieces[pos] = 0;
            let new_pos = (pos as i32 + dxy[action] as i32) as usize;
            new_state.pieces[new_pos] = player;
        } else if action >= 12 && action <= 139 {
            let is_horizontal_wall = action > 75;
            let action = if is_horizontal_wall { action - 75 } else { action - 11 };

            let quotient = (action / 8) as i32;
            let remainder = (action % 8) as i32;

            x = 2 * quotient + if remainder != 0 { 1 } else { -1 };
            y = if remainder != 0 { 2 * remainder - 2 } else { 14 };

            if is_horizontal_wall {
                new_state.pieces[self.convert_xy(x, y)] = wall;
                new_state.pieces[self.convert_xy(x, y + 1)] = wall;
                new_state.pieces[self.convert_xy(x, y + 2)] = wall;
            } else {
                let temp = x;
                x = y;
                y = temp;
                new_state.pieces[self.convert_xy(x, y)] = wall;
                new_state.pieces[self.convert_xy(x + 1, y)] = wall;
                new_state.pieces[self.convert_xy(x + 2, y)] = wall;
            }
        }

        // 교환
        std::mem::swap(&mut new_state.pieces, &mut new_state.enemy_pieces);

        new_state
    }
}

impl fmt::Display for State {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let (pieces0, pieces1) = if self.is_first_player() {
            (&self.pieces, &self.enemy_pieces)
        } else {
            (&self.enemy_pieces, &self.pieces)
        };

        let pw0 = ["", "1", "x"];
        let pw1 = ["", "2", "x"];
        
        let mut result_str = String::new();

        // 후 수 플레이어가 갖고 있는 벽
        let remaining_walls_p1 = 10 - pieces1.iter().filter(|&&x| x == 2).count() / 3;
        result_str.push_str(&format!("[{}]\n", remaining_walls_p1));

        // 보드
        for i in 0..289 {
            if pieces0[i] != 0 {
                result_str.push_str(pw0[pieces0[i] as usize]);
            } else if pieces1[288 - i] != 0 {
                result_str.push_str(pw1[pieces1[288 - i] as usize]);
            } else {
                if i / 17 % 2 == 1 || i % 2 == 1 {
                    result_str.push(' ');
                } else {
                    // Unicode Character 'MIDDLE DOT' (U+00B7)
                    result_str.push('·');
                }
            }

            if i % 17 == 16 {
                result_str.push('\n');
            }
        }

        // 선 수 플레이어가 갖고 있는 벽
        let remaining_walls_p0 = 10 - pieces0.iter().filter(|&&x| x == 2).count() / 3;
        result_str.push_str(&format!("[{}]\n", remaining_walls_p0));

        write!(f, "{}", result_str)
    }
}

fn random_action(state: &State) -> usize {
    let legal_actions = state.legal_actions();
    let mut rng = rand::thread_rng();
    legal_actions[rng.gen_range(0..legal_actions.len())]
}

// 알파베타법을 활용한 상태 가치 계산
fn alpha_beta(state: &State, mut alpha: f64, beta: f64, depth: i32) -> f64 {
    // 패배 시, 상태 가치 -1000
    if state.is_lose() {
        return -1000.0;
    }

    // 무승부 시, 상태 가치 0
    if state.is_draw() {
        return 0.0;
    }

    // 탐색 깊이가 0이면 현재 상태의 보상을 반환
    if depth == 0 {
        return state.reward();
    }

    // 합법적인 수의 상태 가치 계산
    for action in state.pruning_action() {
        let score = -alpha_beta(&state.next(action), -beta, -alpha, depth - 1);
        if score > alpha {
            alpha = score;
        }

        // 현재 노드의 베스트 스코어가 새로운 노드보다 크면 탐색 종료
        if alpha >= beta {
            return alpha;
        }
    }

    // 합법적인 수의 상태 가치의 최대값을 반환
    alpha
}

// 알파베타법을 활용한 행동 선택
fn alpha_beta_action(state: &State, depth: i32) -> usize {
    let mut best_action = 0;
    let mut alpha = f64::NEG_INFINITY;
    let beta = f64::INFINITY;

    // 합법적인 수의 상태 가치 계산
    for action in state.pruning_action() {
        let score = -alpha_beta(&state.next(action), -beta, -alpha, depth);
        if score > alpha {
            best_action = action;
            alpha = score;
        }
    }

    // 합법적인 수의 상태 가치값 중 최대값을 선택하는 행동 반환
    best_action
}


fn main() {
    let mut state = State::new();

    while !state.is_done() {
        let action = alpha_beta_action(&state, 1);
        state = state.next(action);

        println!("{}", state);
    }
}