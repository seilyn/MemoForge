-- ====================================
-- HUBS (비즈니스 엔티티의 고유 키)
-- ====================================

-- 사용자 허브
CREATE TABLE hub_user (
                          user_hk BINARY(16) PRIMARY KEY,  -- MD5/SHA256 해시키
                          user_bk VARCHAR(255) NOT NULL UNIQUE,  -- 비즈니스 키 (email)
                          load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                          record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                          INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 워크스페이스 허브
CREATE TABLE hub_workspace (
                               workspace_hk BINARY(16) PRIMARY KEY,
                               workspace_bk VARCHAR(255) NOT NULL UNIQUE,  -- UUID 또는 slug
                               load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                               record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                               INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 허브
CREATE TABLE hub_page (
                          page_hk BINARY(16) PRIMARY KEY,
                          page_bk VARCHAR(255) NOT NULL UNIQUE,  -- UUID
                          load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                          record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                          INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 블록 허브
CREATE TABLE hub_block (
                           block_hk BINARY(16) PRIMARY KEY,
                           block_bk VARCHAR(255) NOT NULL UNIQUE,  -- UUID
                           load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                           record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                           INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 태그 허브
CREATE TABLE hub_tag (
                         tag_hk BINARY(16) PRIMARY KEY,
                         tag_bk VARCHAR(255) NOT NULL UNIQUE,  -- workspace_id:tag_name
                         load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                         record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                         INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글 허브
CREATE TABLE hub_comment (
                             comment_hk BINARY(16) PRIMARY KEY,
                             comment_bk VARCHAR(255) NOT NULL UNIQUE,  -- UUID
                             load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                             record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                             INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 첨부파일 허브
CREATE TABLE hub_attachment (
                                attachment_hk BINARY(16) PRIMARY KEY,
                                attachment_bk VARCHAR(255) NOT NULL UNIQUE,  -- UUID
                                load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================
-- LINKS (엔티티 간 관계)
-- ====================================

-- 워크스페이스 소유권 링크
CREATE TABLE link_workspace_owner (
                                      link_hk BINARY(16) PRIMARY KEY,
                                      workspace_hk BINARY(16) NOT NULL,
                                      user_hk BINARY(16) NOT NULL,
                                      load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                      record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                      FOREIGN KEY (workspace_hk) REFERENCES hub_workspace(workspace_hk),
                                      FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),
                                      UNIQUE KEY uk_workspace_owner (workspace_hk, user_hk),
                                      INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 워크스페이스 멤버십 링크
CREATE TABLE link_workspace_member (
                                       link_hk BINARY(16) PRIMARY KEY,
                                       workspace_hk BINARY(16) NOT NULL,
                                       user_hk BINARY(16) NOT NULL,
                                       load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                       record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                       FOREIGN KEY (workspace_hk) REFERENCES hub_workspace(workspace_hk),
                                       FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),
                                       UNIQUE KEY uk_workspace_member (workspace_hk, user_hk),
                                       INDEX idx_workspace (workspace_hk),
                                       INDEX idx_user (user_hk),
                                       INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지-워크스페이스 링크
CREATE TABLE link_page_workspace (
                                     link_hk BINARY(16) PRIMARY KEY,
                                     page_hk BINARY(16) NOT NULL,
                                     workspace_hk BINARY(16) NOT NULL,
                                     load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                     record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                     FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                     FOREIGN KEY (workspace_hk) REFERENCES hub_workspace(workspace_hk),
                                     UNIQUE KEY uk_page_workspace (page_hk, workspace_hk),
                                     INDEX idx_workspace (workspace_hk),
                                     INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 계층 구조 링크 (부모-자식)
CREATE TABLE link_page_hierarchy (
                                     link_hk BINARY(16) PRIMARY KEY,
                                     parent_page_hk BINARY(16) NOT NULL,
                                     child_page_hk BINARY(16) NOT NULL,
                                     load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                     record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                     FOREIGN KEY (parent_page_hk) REFERENCES hub_page(page_hk),
                                     FOREIGN KEY (child_page_hk) REFERENCES hub_page(page_hk),
                                     UNIQUE KEY uk_page_hierarchy (parent_page_hk, child_page_hk),
                                     INDEX idx_parent (parent_page_hk),
                                     INDEX idx_child (child_page_hk),
                                     INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 블록-페이지 링크
CREATE TABLE link_block_page (
                                 link_hk BINARY(16) PRIMARY KEY,
                                 block_hk BINARY(16) NOT NULL,
                                 page_hk BINARY(16) NOT NULL,
                                 load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                 record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                 FOREIGN KEY (block_hk) REFERENCES hub_block(block_hk),
                                 FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                 UNIQUE KEY uk_block_page (block_hk, page_hk),
                                 INDEX idx_page (page_hk),
                                 INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 블록 계층 구조 링크
CREATE TABLE link_block_hierarchy (
                                      link_hk BINARY(16) PRIMARY KEY,
                                      parent_block_hk BINARY(16) NOT NULL,
                                      child_block_hk BINARY(16) NOT NULL,
                                      load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                      record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                      FOREIGN KEY (parent_block_hk) REFERENCES hub_block(block_hk),
                                      FOREIGN KEY (child_block_hk) REFERENCES hub_block(block_hk),
                                      UNIQUE KEY uk_block_hierarchy (parent_block_hk, child_block_hk),
                                      INDEX idx_parent (parent_block_hk),
                                      INDEX idx_child (child_block_hk),
                                      INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지-태그 링크
CREATE TABLE link_page_tag (
                               link_hk BINARY(16) PRIMARY KEY,
                               page_hk BINARY(16) NOT NULL,
                               tag_hk BINARY(16) NOT NULL,
                               load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                               record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                               FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                               FOREIGN KEY (tag_hk) REFERENCES hub_tag(tag_hk),
                               UNIQUE KEY uk_page_tag (page_hk, tag_hk),
                               INDEX idx_tag (tag_hk),
                               INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글-페이지 링크
CREATE TABLE link_comment_page (
                                   link_hk BINARY(16) PRIMARY KEY,
                                   comment_hk BINARY(16) NOT NULL,
                                   page_hk BINARY(16) NOT NULL,
                                   load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                   record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                   FOREIGN KEY (comment_hk) REFERENCES hub_comment(comment_hk),
                                   FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                   UNIQUE KEY uk_comment_page (comment_hk, page_hk),
                                   INDEX idx_page (page_hk),
                                   INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글-블록 링크
CREATE TABLE link_comment_block (
                                    link_hk BINARY(16) PRIMARY KEY,
                                    comment_hk BINARY(16) NOT NULL,
                                    block_hk BINARY(16) NOT NULL,
                                    load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                    record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                    FOREIGN KEY (comment_hk) REFERENCES hub_comment(comment_hk),
                                    FOREIGN KEY (block_hk) REFERENCES hub_block(block_hk),
                                    UNIQUE KEY uk_comment_block (comment_hk, block_hk),
                                    INDEX idx_block (block_hk),
                                    INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글-작성자 링크
CREATE TABLE link_comment_author (
                                     link_hk BINARY(16) PRIMARY KEY,
                                     comment_hk BINARY(16) NOT NULL,
                                     user_hk BINARY(16) NOT NULL,
                                     load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                     record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                     FOREIGN KEY (comment_hk) REFERENCES hub_comment(comment_hk),
                                     FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),
                                     UNIQUE KEY uk_comment_author (comment_hk, user_hk),
                                     INDEX idx_user (user_hk),
                                     INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 공유 링크
CREATE TABLE link_page_share (
                                 link_hk BINARY(16) PRIMARY KEY,
                                 page_hk BINARY(16) NOT NULL,
                                 user_hk BINARY(16) NOT NULL,
                                 load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                 record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                 FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                 FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),
                                 UNIQUE KEY uk_page_share (page_hk, user_hk),
                                 INDEX idx_user (user_hk),
                                 INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 첨부파일-페이지 링크
CREATE TABLE link_attachment_page (
                                      link_hk BINARY(16) PRIMARY KEY,
                                      attachment_hk BINARY(16) NOT NULL,
                                      page_hk BINARY(16) NOT NULL,
                                      load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                      record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                      FOREIGN KEY (attachment_hk) REFERENCES hub_attachment(attachment_hk),
                                      FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                      UNIQUE KEY uk_attachment_page (attachment_hk, page_hk),
                                      INDEX idx_page (page_hk),
                                      INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 첨부파일-블록 링크
CREATE TABLE link_attachment_block (
                                       link_hk BINARY(16) PRIMARY KEY,
                                       attachment_hk BINARY(16) NOT NULL,
                                       block_hk BINARY(16) NOT NULL,
                                       load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                       record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                       FOREIGN KEY (attachment_hk) REFERENCES hub_attachment(attachment_hk),
                                       FOREIGN KEY (block_hk) REFERENCES hub_block(block_hk),
                                       UNIQUE KEY uk_attachment_block (attachment_hk, block_hk),
                                       INDEX idx_block (block_hk),
                                       INDEX idx_load_date (load_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================
-- SATELLITES (속성 및 이력)
-- ====================================

-- 사용자 프로필 새틀라이트
CREATE TABLE sat_user_profile (
                                  user_hk BINARY(16) NOT NULL,
                                  load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                  load_end_date TIMESTAMP(6) NULL,  -- 이력 종료 시점
                                  hash_diff BINARY(16) NOT NULL,  -- 변경 감지용 해시

                                  name VARCHAR(100) NOT NULL,
                                  password_hash VARCHAR(255) NOT NULL,
                                  profile_image_url TEXT,
                                  status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE',

                                  record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                  FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),
                                  PRIMARY KEY (user_hk, load_date),
                                  INDEX idx_load_end_date (load_end_date),
                                  INDEX idx_hash_diff (hash_diff)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 워크스페이스 속성 새틀라이트
CREATE TABLE sat_workspace_details (
                                       workspace_hk BINARY(16) NOT NULL,
                                       load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                       load_end_date TIMESTAMP(6) NULL,
                                       hash_diff BINARY(16) NOT NULL,

                                       name VARCHAR(200) NOT NULL,
                                       icon VARCHAR(50),
                                       plan ENUM('FREE', 'PERSONAL', 'TEAM', 'ENTERPRISE') DEFAULT 'FREE',
                                       settings JSON,

                                       record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                       FOREIGN KEY (workspace_hk) REFERENCES hub_workspace(workspace_hk),
                                       PRIMARY KEY (workspace_hk, load_date),
                                       INDEX idx_load_end_date (load_end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 워크스페이스 멤버 역할 새틀라이트
CREATE TABLE sat_workspace_member_role (
                                           link_hk BINARY(16) NOT NULL,
                                           load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                           load_end_date TIMESTAMP(6) NULL,
                                           hash_diff BINARY(16) NOT NULL,

                                           role ENUM('OWNER', 'ADMIN', 'MEMBER', 'GUEST') DEFAULT 'MEMBER',
                                           invited_by_user_hk BINARY(16),
                                           invited_at TIMESTAMP(6),
                                           joined_at TIMESTAMP(6),

                                           record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                           FOREIGN KEY (link_hk) REFERENCES link_workspace_member(link_hk),
                                           PRIMARY KEY (link_hk, load_date),
                                           INDEX idx_load_end_date (load_end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 속성 새틀라이트
CREATE TABLE sat_page_details (
                                  page_hk BINARY(16) NOT NULL,
                                  load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                  load_end_date TIMESTAMP(6) NULL,
                                  hash_diff BINARY(16) NOT NULL,

                                  title VARCHAR(500) DEFAULT 'Untitled',
                                  icon VARCHAR(50),
                                  cover_image_url TEXT,

    -- 계층 구조 정보 (쿼리 성능을 위해 비정규화)
                                  path VARCHAR(1000),
                                  depth TINYINT UNSIGNED DEFAULT 0,

                                  is_archived BOOLEAN DEFAULT FALSE,
                                  is_template BOOLEAN DEFAULT FALSE,
                                  is_public BOOLEAN DEFAULT FALSE,

                                  record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                  FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                  PRIMARY KEY (page_hk, load_date),
                                  INDEX idx_load_end_date (load_end_date),
                                  INDEX idx_path (path(255)),
                                  FULLTEXT INDEX ft_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 메타데이터 새틀라이트
CREATE TABLE sat_page_metadata (
                                   page_hk BINARY(16) NOT NULL,
                                   load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                   load_end_date TIMESTAMP(6) NULL,
                                   hash_diff BINARY(16) NOT NULL,

                                   created_by_user_hk BINARY(16) NOT NULL,
                                   updated_by_user_hk BINARY(16) NOT NULL,
                                   last_edited_at TIMESTAMP(6),

                                   record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                   FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                   PRIMARY KEY (page_hk, load_date),
                                   INDEX idx_load_end_date (load_end_date),
                                   INDEX idx_last_edited (last_edited_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 블록 속성 새틀라이트
CREATE TABLE sat_block_details (
                                   block_hk BINARY(16) NOT NULL,
                                   load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                   load_end_date TIMESTAMP(6) NULL,
                                   hash_diff BINARY(16) NOT NULL,

                                   block_type ENUM(
                                       'PARAGRAPH', 'HEADING_1', 'HEADING_2', 'HEADING_3',
                                       'BULLETED_LIST', 'NUMBERED_LIST', 'TODO',
                                       'TOGGLE', 'QUOTE', 'CALLOUT', 'CODE',
                                       'IMAGE', 'VIDEO', 'FILE', 'EMBED',
                                       'DIVIDER', 'TABLE_OF_CONTENTS',
                                       'TABLE', 'TABLE_ROW',
                                       'COLUMN', 'COLUMN_LIST',
                                       'DATABASE', 'DATABASE_ROW'
                                       ) NOT NULL,

                                   position VARCHAR(50) NOT NULL,  -- Fractional indexing
                                   content_text TEXT,
                                   content_meta JSON,
                                   properties JSON,

                                   is_archived BOOLEAN DEFAULT FALSE,

                                   record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                   FOREIGN KEY (block_hk) REFERENCES hub_block(block_hk),
                                   PRIMARY KEY (block_hk, load_date),
                                   INDEX idx_load_end_date (load_end_date),
                                   INDEX idx_position (position),
                                   FULLTEXT INDEX ft_content (content_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 태그 속성 새틀라이트
CREATE TABLE sat_tag_details (
                                 tag_hk BINARY(16) NOT NULL,
                                 load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                 load_end_date TIMESTAMP(6) NULL,
                                 hash_diff BINARY(16) NOT NULL,

                                 name VARCHAR(100) NOT NULL,
                                 color VARCHAR(20),

                                 record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                 FOREIGN KEY (tag_hk) REFERENCES hub_tag(tag_hk),
                                 PRIMARY KEY (tag_hk, load_date),
                                 INDEX idx_load_end_date (load_end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 댓글 내용 새틀라이트
CREATE TABLE sat_comment_content (
                                     comment_hk BINARY(16) NOT NULL,
                                     load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                     load_end_date TIMESTAMP(6) NULL,
                                     hash_diff BINARY(16) NOT NULL,

                                     content TEXT NOT NULL,
                                     mentions JSON,
                                     is_resolved BOOLEAN DEFAULT FALSE,
                                     resolved_by_user_hk BINARY(16),
                                     resolved_at TIMESTAMP(6),

                                     record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                     FOREIGN KEY (comment_hk) REFERENCES hub_comment(comment_hk),
                                     PRIMARY KEY (comment_hk, load_date),
                                     INDEX idx_load_end_date (load_end_date),
                                     INDEX idx_resolved (is_resolved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 페이지 공유 권한 새틀라이트
CREATE TABLE sat_page_share_permission (
                                           link_hk BINARY(16) NOT NULL,
                                           load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                           load_end_date TIMESTAMP(6) NULL,
                                           hash_diff BINARY(16) NOT NULL,

                                           permission ENUM('VIEW', 'COMMENT', 'EDIT', 'FULL') DEFAULT 'VIEW',
                                           share_token VARCHAR(100),
                                           is_public_link BOOLEAN DEFAULT FALSE,
                                           allow_duplicate BOOLEAN DEFAULT FALSE,
                                           allow_search_engine BOOLEAN DEFAULT FALSE,
                                           expires_at TIMESTAMP(6),
                                           shared_by_user_hk BINARY(16) NOT NULL,

                                           record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                           FOREIGN KEY (link_hk) REFERENCES link_page_share(link_hk),
                                           PRIMARY KEY (link_hk, load_date),
                                           INDEX idx_load_end_date (load_end_date),
                                           INDEX idx_token (share_token),
                                           INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 첨부파일 속성 새틀라이트
CREATE TABLE sat_attachment_details (
                                        attachment_hk BINARY(16) NOT NULL,
                                        load_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                        load_end_date TIMESTAMP(6) NULL,
                                        hash_diff BINARY(16) NOT NULL,

                                        file_name VARCHAR(500) NOT NULL,
                                        file_url TEXT NOT NULL,
                                        file_type VARCHAR(100),
                                        file_size BIGINT UNSIGNED,
                                        thumbnail_url TEXT,
                                        created_by_user_hk BINARY(16) NOT NULL,

                                        record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                        FOREIGN KEY (attachment_hk) REFERENCES hub_attachment(attachment_hk),
                                        PRIMARY KEY (attachment_hk, load_date),
                                        INDEX idx_load_end_date (load_end_date),
                                        INDEX idx_file_type (file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================
-- 비즈니스 뷰 (쿼리 편의성을 위한 뷰)
-- ====================================

-- 현재 활성화된 사용자 뷰
CREATE VIEW v_current_users AS
SELECT
    hu.user_hk,
    hu.user_bk as email,
    sup.name,
    sup.profile_image_url,
    sup.status,
    sup.load_date as current_from
FROM hub_user hu
         JOIN sat_user_profile sup ON hu.user_hk = sup.user_hk
WHERE sup.load_end_date IS NULL;  -- 현재 유효한 레코드만

-- 현재 활성화된 페이지 뷰
CREATE VIEW v_current_pages AS
SELECT
    hp.page_hk,
    hp.page_bk,
    spd.title,
    spd.icon,
    spd.cover_image_url,
    spd.path,
    spd.depth,
    spd.is_archived,
    spd.is_template,
    spm.last_edited_at,
    lpw.workspace_hk
FROM hub_page hp
         JOIN sat_page_details spd ON hp.page_hk = spd.page_hk
         JOIN sat_page_metadata spm ON hp.page_hk = spm.page_hk
         JOIN link_page_workspace lpw ON hp.page_hk = lpw.page_hk
WHERE spd.load_end_date IS NULL
  AND spm.load_end_date IS NULL
  AND spd.is_archived = FALSE;

-- 현재 활성화된 블록 뷰
CREATE VIEW v_current_blocks AS
SELECT
    hb.block_hk,
    hb.block_bk,
    sbd.block_type,
    sbd.position,
    sbd.content_text,
    sbd.content_meta,
    sbd.properties,
    lbp.page_hk
FROM hub_block hb
         JOIN sat_block_details sbd ON hb.block_hk = sbd.block_hk
         JOIN link_block_page lbp ON hb.block_hk = lbp.block_hk
WHERE sbd.load_end_date IS NULL
  AND sbd.is_archived = FALSE;

-- ====================================
-- 헬퍼 함수
-- ====================================

DELIMITER //

-- 비즈니스 키로부터 해시키 생성
CREATE FUNCTION generate_hash_key(business_key VARCHAR(255))
    RETURNS BINARY(16)
    DETERMINISTIC
BEGIN
    RETURN UNHEX(MD5(business_key));
END//

-- 변경 감지용 해시 생성
CREATE FUNCTION generate_hash_diff(data TEXT)
    RETURNS BINARY(16)
    DETERMINISTIC
BEGIN
    RETURN UNHEX(MD5(data));
END//

DELIMITER ;




CREATE TABLE page_edit_lock (
                                lock_id BINARY(16) PRIMARY KEY,            -- 개별 락 식별자 (UUID 해시 등)
                                page_hk BINARY(16) NOT NULL,              -- 잠그는 페이지
                                user_hk BINARY(16) NOT NULL,              -- 락 잡은 사용자
                                lock_token VARCHAR(64) NOT NULL,          -- 클라이언트/세션 식별용 토큰
                                acquired_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
                                expires_at TIMESTAMP(6) NOT NULL,         -- 락 만료 시각 (방치 방지)
                                is_active BOOLEAN DEFAULT TRUE,           -- 현재 유효한 락 여부
                                record_source VARCHAR(50) DEFAULT 'MINI_NOTION',

                                FOREIGN KEY (page_hk) REFERENCES hub_page(page_hk),
                                FOREIGN KEY (user_hk) REFERENCES hub_user(user_hk),

    -- 한 페이지에 동시에 active 락은 1개만 허용
                                UNIQUE KEY uk_page_active_lock (page_hk, is_active),

                                INDEX idx_page (page_hk),
                                INDEX idx_user (user_hk),
                                INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
