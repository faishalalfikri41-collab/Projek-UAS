-- =====================================================================
-- PROJECT UAS DATABASE ORACLE - SISTEM PERPUSTAKAAN
-- Database : Oracle Database 21c XE (koneksi uas-xe, user UAS, XEPDB1)
-- Isi      : 0) bersih-bersih  1) DDL tabel  2) data contoh
--            3) view  4) function  5) query demo
-- Cara     : jalankan dengan "Run Script" (F5), BUKAN Ctrl+Enter
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0) BERSIH-BERSIH (aman dijalankan berulang kali)
-- ---------------------------------------------------------------------
BEGIN
  FOR t IN (SELECT table_name
              FROM user_tables
             WHERE table_name IN ('DENDA','PEMINJAMAN','BUKU','KATEGORI','ANGGOTA'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

-- ---------------------------------------------------------------------
-- 1) DDL TABEL
-- ---------------------------------------------------------------------

-- 1.1) ANGGOTA
CREATE TABLE anggota (
    id_anggota      NUMBER GENERATED ALWAYS AS IDENTITY,
    nama            VARCHAR2(100)  NOT NULL,
    email           VARCHAR2(100)  NOT NULL,
    no_telepon      VARCHAR2(20),
    alamat          VARCHAR2(255),
    tanggal_daftar  DATE           DEFAULT SYSDATE NOT NULL,
    status          VARCHAR2(20)   DEFAULT 'AKTIF' NOT NULL,
    CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
    CONSTRAINT uq_anggota_email UNIQUE (email),
    CONSTRAINT ck_anggota_status CHECK (status IN ('AKTIF', 'NONAKTIF'))
);

-- 1.2) KATEGORI
CREATE TABLE kategori (
    id_kategori    NUMBER GENERATED ALWAYS AS IDENTITY,
    nama_kategori  VARCHAR2(100) NOT NULL,
    deskripsi      VARCHAR2(255),
    CONSTRAINT pk_kategori PRIMARY KEY (id_kategori),
    CONSTRAINT uq_kategori_nama UNIQUE (nama_kategori)
);

-- 1.3) BUKU
CREATE TABLE buku (
    id_buku        NUMBER GENERATED ALWAYS AS IDENTITY,
    id_kategori    NUMBER        NOT NULL,
    judul          VARCHAR2(200) NOT NULL,
    penulis        VARCHAR2(100) NOT NULL,
    penerbit       VARCHAR2(100),
    tahun_terbit   NUMBER(4),
    isbn           VARCHAR2(20),
    stok           NUMBER        DEFAULT 0 NOT NULL,
    CONSTRAINT pk_buku PRIMARY KEY (id_buku),
    CONSTRAINT fk_buku_kategori FOREIGN KEY (id_kategori)
        REFERENCES kategori (id_kategori),
    CONSTRAINT uq_buku_isbn UNIQUE (isbn),
    CONSTRAINT ck_buku_stok CHECK (stok >= 0),
    CONSTRAINT ck_buku_tahun_terbit CHECK (tahun_terbit BETWEEN 1900 AND 2100)
);

-- 1.4) PEMINJAMAN
CREATE TABLE peminjaman (
    id_peminjaman       NUMBER GENERATED ALWAYS AS IDENTITY,
    id_anggota          NUMBER       NOT NULL,
    id_buku             NUMBER       NOT NULL,
    tanggal_pinjam      DATE         DEFAULT SYSDATE NOT NULL,
    tanggal_jatuh_tempo DATE         NOT NULL,
    tanggal_kembali     DATE,
    status              VARCHAR2(20) DEFAULT 'DIPINJAM' NOT NULL,
    CONSTRAINT pk_peminjaman PRIMARY KEY (id_peminjaman),
    CONSTRAINT fk_peminjaman_anggota FOREIGN KEY (id_anggota)
        REFERENCES anggota (id_anggota),
    CONSTRAINT fk_peminjaman_buku FOREIGN KEY (id_buku)
        REFERENCES buku (id_buku),
    CONSTRAINT ck_peminjaman_status CHECK (status IN ('DIPINJAM', 'DIKEMBALIKAN', 'TERLAMBAT')),
    CONSTRAINT ck_peminjaman_tanggal CHECK (tanggal_jatuh_tempo >= tanggal_pinjam),
    CONSTRAINT ck_peminjaman_kembali CHECK (
        tanggal_kembali IS NULL OR tanggal_kembali >= tanggal_pinjam
    )
);

-- 1.5) DENDA
CREATE TABLE denda (
    id_denda       NUMBER GENERATED ALWAYS AS IDENTITY,
    id_peminjaman  NUMBER        NOT NULL,
    jumlah_denda   NUMBER(12,2)  NOT NULL,
    tanggal_bayar  DATE,
    status_denda   VARCHAR2(20)  DEFAULT 'BELUM_BAYAR' NOT NULL,
    CONSTRAINT pk_denda PRIMARY KEY (id_denda),
    CONSTRAINT fk_denda_peminjaman FOREIGN KEY (id_peminjaman)
        REFERENCES peminjaman (id_peminjaman),
    CONSTRAINT uq_denda_peminjaman UNIQUE (id_peminjaman),
    CONSTRAINT ck_denda_jumlah CHECK (jumlah_denda >= 0),
    CONSTRAINT ck_denda_status CHECK (status_denda IN ('BELUM_BAYAR', 'LUNAS'))
);

-- ---------------------------------------------------------------------
-- 2) DATA CONTOH
--    ID memakai IDENTITY, jadi relasi diisi lewat lookup (email / isbn),
--    bukan angka ID yang ditebak.
-- ---------------------------------------------------------------------

-- 2.1) KATEGORI (7 baris)
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Fiksi',      'Novel dan cerita fiksi');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Sejarah',    'Buku sejarah dan sastra sejarah');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Teknologi',  'Komputer, pemrograman, dan basis data');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Nonfiksi',   'Pengembangan diri dan pengetahuan umum');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Bisnis',     'Keuangan, bisnis, dan kewirausahaan');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Biografi',   'Kisah hidup tokoh');
INSERT INTO kategori (nama_kategori, deskripsi) VALUES ('Anak-anak',  'Bacaan dan ensiklopedia anak');

-- 2.2) ANGGOTA (10 baris)
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Ani Lestari',     'ani.lestari@mail.com',     '081234560001', 'Jl. Melati No. 1, Tangerang Selatan',  DATE '2026-01-10', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Budi Santoso',    'budi.santoso@mail.com',    '081234560002', 'Jl. Kenanga No. 2, Jakarta Selatan',   DATE '2026-01-15', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Citra Dewi',      'citra.dewi@mail.com',      '081234560003', 'Jl. Mawar No. 3, Depok',               DATE '2026-02-01', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Dedi Kurniawan',  'dedi.kurniawan@mail.com',  '081234560004', 'Jl. Anggrek No. 4, Bekasi',            DATE '2026-02-12', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Eka Putri',       'eka.putri@mail.com',       '081234560005', 'Jl. Dahlia No. 5, Bogor',              DATE '2026-03-03', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Fajar Ramadhan',  'fajar.ramadhan@mail.com',  '081234560006', 'Jl. Flamboyan No. 6, Tangerang',       DATE '2026-03-20', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Gita Permata',    'gita.permata@mail.com',    '081234560007', 'Jl. Cempaka No. 7, Jakarta Timur',     DATE '2026-04-05', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Hadi Prasetyo',   'hadi.prasetyo@mail.com',   '081234560008', 'Jl. Teratai No. 8, Jakarta Barat',     DATE '2026-04-18', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Indah Sari',      'indah.sari@mail.com',      '081234560009', 'Jl. Seruni No. 9, Depok',              DATE '2026-05-02', 'AKTIF');
INSERT INTO anggota (nama, email, no_telepon, alamat, tanggal_daftar, status)
VALUES ('Joko Widodo Putra','joko.putra@mail.com',     '081234560010', 'Jl. Kamboja No. 10, Bekasi',           DATE '2026-05-20', 'NONAKTIF');

-- 2.3) BUKU (10 baris). ISBN di bawah hanyalah contoh data.
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Laskar Pelangi', 'Andrea Hirata', 'Bentang Pustaka', 2005, '9789793062792', 5
  FROM kategori WHERE nama_kategori = 'Fiksi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Bumi Manusia', 'Pramoedya Ananta Toer', 'Hasta Mitra', 1980, '9789799731234', 3
  FROM kategori WHERE nama_kategori = 'Sejarah';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Janji', 'Tere Liye', 'Sabak Grip', 2021, '9786239726001', 4
  FROM kategori WHERE nama_kategori = 'Fiksi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Dasar-Dasar Basis Data', 'Abdul Kadir', 'Andi Offset', 2018, '9789792900011', 6
  FROM kategori WHERE nama_kategori = 'Teknologi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Algoritma dan Pemrograman Python', 'Rinaldi Munir', 'Informatika Bandung', 2016, '9786026231022', 4
  FROM kategori WHERE nama_kategori = 'Teknologi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Sapiens', 'Yuval Noah Harari', 'Kepustakaan Populer Gramedia', 2017, '9786024811033', 3
  FROM kategori WHERE nama_kategori = 'Sejarah';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Atomic Habits', 'James Clear', 'Gramedia Pustaka Utama', 2019, '9786020633176', 5
  FROM kategori WHERE nama_kategori = 'Nonfiksi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Rich Dad Poor Dad', 'Robert T. Kiyosaki', 'Gramedia Pustaka Utama', 2011, '9789792251204', 2
  FROM kategori WHERE nama_kategori = 'Bisnis';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Habibie & Ainun', 'B. J. Habibie', 'THC Mandiri', 2010, '9786029020052', 3
  FROM kategori WHERE nama_kategori = 'Biografi';
INSERT INTO buku (id_kategori, judul, penulis, penerbit, tahun_terbit, isbn, stok)
SELECT id_kategori, 'Ensiklopedia Sains Anak', 'Tim Redaksi', 'Erlangga for Kids', 2019, '9786022981167', 7
  FROM kategori WHERE nama_kategori = 'Anak-anak';

-- 2.4) PEMINJAMAN (10 baris)
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-01', DATE '2026-11-08', DATE '2026-11-07', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'ani.lestari@mail.com' AND b.isbn = '9789793062792';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-02', DATE '2026-11-09', DATE '2026-11-15', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'budi.santoso@mail.com' AND b.isbn = '9789792900011';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-03', DATE '2026-11-10', NULL, 'TERLAMBAT'
  FROM anggota a, buku b WHERE a.email = 'citra.dewi@mail.com' AND b.isbn = '9786239726001';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-05', DATE '2026-11-12', DATE '2026-11-12', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'dedi.kurniawan@mail.com' AND b.isbn = '9786026231022';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-10-20', DATE '2026-10-27', DATE '2026-11-05', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'eka.putri@mail.com' AND b.isbn = '9786024811033';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-10', DATE '2026-11-17', DATE '2026-11-16', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'fajar.ramadhan@mail.com' AND b.isbn = '9786020633176';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-12', DATE '2026-11-19', NULL, 'TERLAMBAT'
  FROM anggota a, buku b WHERE a.email = 'gita.permata@mail.com' AND b.isbn = '9789792251204';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-20', DATE '2026-11-27', NULL, 'DIPINJAM'
  FROM anggota a, buku b WHERE a.email = 'hadi.prasetyo@mail.com' AND b.isbn = '9786029020052';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-11-22', DATE '2026-11-29', NULL, 'DIPINJAM'
  FROM anggota a, buku b WHERE a.email = 'indah.sari@mail.com' AND b.isbn = '9786022981167';
INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam, tanggal_jatuh_tempo, tanggal_kembali, status)
SELECT a.id_anggota, b.id_buku, DATE '2026-10-25', DATE '2026-11-01', DATE '2026-11-04', 'DIKEMBALIKAN'
  FROM anggota a, buku b WHERE a.email = 'joko.putra@mail.com' AND b.isbn = '9789799731234';

-- 2.5) DENDA (5 baris, tarif Rp2.000 per hari keterlambatan)
INSERT INTO denda (id_peminjaman, jumlah_denda, tanggal_bayar, status_denda)
SELECT p.id_peminjaman, 12000, DATE '2026-11-15', 'LUNAS'
  FROM peminjaman p JOIN anggota a ON a.id_anggota = p.id_anggota
 WHERE a.email = 'budi.santoso@mail.com';
INSERT INTO denda (id_peminjaman, jumlah_denda, tanggal_bayar, status_denda)
SELECT p.id_peminjaman, 30000, NULL, 'BELUM_BAYAR'
  FROM peminjaman p JOIN anggota a ON a.id_anggota = p.id_anggota
 WHERE a.email = 'citra.dewi@mail.com';
INSERT INTO denda (id_peminjaman, jumlah_denda, tanggal_bayar, status_denda)
SELECT p.id_peminjaman, 18000, DATE '2026-11-05', 'LUNAS'
  FROM peminjaman p JOIN anggota a ON a.id_anggota = p.id_anggota
 WHERE a.email = 'eka.putri@mail.com';
INSERT INTO denda (id_peminjaman, jumlah_denda, tanggal_bayar, status_denda)
SELECT p.id_peminjaman, 12000, NULL, 'BELUM_BAYAR'
  FROM peminjaman p JOIN anggota a ON a.id_anggota = p.id_anggota
 WHERE a.email = 'gita.permata@mail.com';
INSERT INTO denda (id_peminjaman, jumlah_denda, tanggal_bayar, status_denda)
SELECT p.id_peminjaman, 6000, DATE '2026-11-04', 'LUNAS'
  FROM peminjaman p JOIN anggota a ON a.id_anggota = p.id_anggota
 WHERE a.email = 'joko.putra@mail.com';

COMMIT;

-- ---------------------------------------------------------------------
-- 3) VIEW
-- ---------------------------------------------------------------------

-- 3.1) Daftar peminjaman lengkap (gabungan 4 tabel)
CREATE OR REPLACE VIEW v_peminjaman_detail AS
SELECT p.id_peminjaman,
       a.nama            AS nama_anggota,
       b.judul           AS judul_buku,
       k.nama_kategori,
       p.tanggal_pinjam,
       p.tanggal_jatuh_tempo,
       p.tanggal_kembali,
       p.status
  FROM peminjaman p
  JOIN anggota  a ON a.id_anggota  = p.id_anggota
  JOIN buku     b ON b.id_buku     = p.id_buku
  JOIN kategori k ON k.id_kategori = b.id_kategori;

-- 3.2) Laporan denda per anggota
CREATE OR REPLACE VIEW v_laporan_denda AS
SELECT a.nama,
       b.judul,
       d.jumlah_denda,
       d.status_denda,
       d.tanggal_bayar
  FROM denda d
  JOIN peminjaman p ON p.id_peminjaman = d.id_peminjaman
  JOIN anggota    a ON a.id_anggota    = p.id_anggota
  JOIN buku       b ON b.id_buku       = p.id_buku;

-- ---------------------------------------------------------------------
-- 4) FUNCTION: hitung denda (Rp2.000 per hari terlambat)
--    Kalau buku belum kembali, dihitung sampai hari ini (SYSDATE).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_hitung_denda (p_id_peminjaman IN NUMBER)
RETURN NUMBER
IS
    v_jatuh_tempo DATE;
    v_kembali     DATE;
    v_hari        NUMBER;
BEGIN
    SELECT tanggal_jatuh_tempo, tanggal_kembali
      INTO v_jatuh_tempo, v_kembali
      FROM peminjaman
     WHERE id_peminjaman = p_id_peminjaman;

    v_hari := TRUNC(NVL(v_kembali, SYSDATE)) - TRUNC(v_jatuh_tempo);
    IF v_hari < 0 THEN
        v_hari := 0;
    END IF;

    RETURN v_hari * 2000;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END fn_hitung_denda;
/

-- ---------------------------------------------------------------------
-- 5) QUERY DEMO (jalankan satu per satu dengan Ctrl+Enter)
-- ---------------------------------------------------------------------

-- 5.1) Cek jumlah data tiap tabel
SELECT 'ANGGOTA' AS tabel, COUNT(*) AS jumlah FROM anggota
UNION ALL SELECT 'KATEGORI',   COUNT(*) FROM kategori
UNION ALL SELECT 'BUKU',       COUNT(*) FROM buku
UNION ALL SELECT 'PEMINJAMAN', COUNT(*) FROM peminjaman
UNION ALL SELECT 'DENDA',      COUNT(*) FROM denda;

-- 5.2) Semua peminjaman beserta nama anggota dan judul buku
SELECT * FROM v_peminjaman_detail ORDER BY tanggal_pinjam;

-- 5.3) Buku yang sedang dipinjam atau terlambat (belum kembali)
SELECT nama_anggota, judul_buku, tanggal_jatuh_tempo, status
  FROM v_peminjaman_detail
 WHERE tanggal_kembali IS NULL;

-- 5.4) Total denda yang belum dibayar per anggota
SELECT nama, SUM(jumlah_denda) AS total_belum_bayar
  FROM v_laporan_denda
 WHERE status_denda = 'BELUM_BAYAR'
 GROUP BY nama
 ORDER BY total_belum_bayar DESC;

-- 5.5) Jumlah buku per kategori
SELECT k.nama_kategori, COUNT(b.id_buku) AS jumlah_judul, NVL(SUM(b.stok), 0) AS total_stok
  FROM kategori k
  LEFT JOIN buku b ON b.id_kategori = k.id_kategori
 GROUP BY k.nama_kategori
 ORDER BY jumlah_judul DESC;

-- 5.6) Anggota yang paling sering meminjam
SELECT a.nama, COUNT(p.id_peminjaman) AS jumlah_pinjam
  FROM anggota a
  LEFT JOIN peminjaman p ON p.id_anggota = a.id_anggota
 GROUP BY a.nama
 ORDER BY jumlah_pinjam DESC, a.nama;

-- 5.7) Tes function denda: hitung ulang denda tiap peminjaman
SELECT id_peminjaman, nama_anggota, judul_buku,
       fn_hitung_denda(id_peminjaman) AS denda_dihitung
  FROM v_peminjaman_detail
 ORDER BY id_peminjaman;
 