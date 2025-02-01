;; QuestForge Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-quest (err u102))

;; Data Variables
(define-data-var next-quest-id uint u0)

;; Data Maps
(define-map players principal
  {
    level: uint,
    experience: uint,
    completed-quests: uint
  }
)

(define-map quests uint
  {
    owner: principal,
    title: (string-ascii 50),
    difficulty: uint,
    completed: bool,
    experience-reward: uint
  }
)

;; Player Functions
(define-public (initialize-player)
  (ok (map-set players tx-sender {
    level: u1,
    experience: u0,
    completed-quests: u0
  }))
)

(define-public (create-quest (title (string-ascii 50)) (difficulty uint))
  (let
    (
      (quest-id (var-get next-quest-id))
      (exp-reward (* difficulty u10))
    )
    (map-set quests quest-id {
      owner: tx-sender,
      title: title,
      difficulty: difficulty,
      completed: false,
      experience-reward: exp-reward
    })
    (var-set next-quest-id (+ quest-id u1))
    (ok quest-id)
  )
)

(define-public (complete-quest (quest-id uint))
  (let
    (
      (quest (unwrap! (map-get? quests quest-id) (err err-not-found)))
      (player (unwrap! (map-get? players tx-sender) (err err-not-found)))
    )
    (asserts! (is-eq (get owner quest) tx-sender) (err err-invalid-quest))
    (asserts! (not (get completed quest)) (err err-invalid-quest))
    
    (map-set quests quest-id (merge quest { completed: true }))
    (map-set players tx-sender (merge player {
      experience: (+ (get experience player) (get experience-reward quest)),
      completed-quests: (+ (get completed-quests player) u1)
    }))
    
    (ok true)
  )
)

;; Read Functions
(define-read-only (get-player-info (player principal))
  (map-get? players player)
)

(define-read-only (get-quest (quest-id uint))
  (map-get? quests quest-id)
)
