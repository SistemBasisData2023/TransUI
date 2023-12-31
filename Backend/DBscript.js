const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');
const path = require('path')

const app = express();
const router = require('./Bridge');
const port = 3000;

app.use('/css', express.static(path.join(__dirname, '../css')));
app.use(express.static('public'));
app.use('/public', express.static(path.join(__dirname, '../public')));
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

//Fungsi Import
const { generateUserID } = require('./userController');
const topUpRouter = require('./top-up');


// Konfigurasi koneksi database
const pool = new Pool({
    connectionString: 'postgres://rezkimuhammad60:3tbwJKEXYjo1@ep-empty-recipe-891243-pooler.ap-southeast-1.aws.neon.tech/TransUI',
    sslmode: "require",
    ssl: true
});

// Middleware untuk menguraikan body permintaan
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static('public'));
app.use('/', router);

// Middleware untuk session
app.use(session({
    secret: 'secret-key',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: true, maxAge: 3600000 }
}));

// function requireAuth(req, res, next) {
//     if (req.session.userId) {
//         // Lanjutkan jika pengguna telah terotentikasi
//         next();
//     } else {
//         // Kirim respons jika pengguna tidak terotentikasi
//         res.status(401).json({ message: 'Unauthorized' });
//     }
// }

// Rute untuk registrasi pengguna
app.post('/api/register', async (req, res) => {
    try {
        const { username, password, email, role } = req.body;

        // Cek apakah username sudah digunakan sebelumnya
        const usernameExists = await pool.query('SELECT * FROM user_table WHERE username = $1', [username]);
        if (usernameExists.rows.length > 0) {
            return res.status(400).json({ message: 'Username sudah digunakan' });
        }

        // Cek apakah email sudah digunakan sebelumnya
        const emailExists = await pool.query('SELECT * FROM user_table WHERE email = $1', [email]);
        if (emailExists.rows.length > 0) {
            return res.status(400).json({ message: 'Email sudah digunakan' });
        }

        // Enkripsi password
        //const hashedPassword = await bcrypt.hash(password, 10);

        // Generate User ID
        const userID = await generateUserID(pool);

        // Simpan data pengguna ke tabel user_table 
        const result = await pool.query('INSERT INTO user_table (user_id, username, password, email, role) VALUES ($1, $2, $3, $4, $5) RETURNING *', [userID, username, password, email, role]);

        // Mengirimkan respons berhasil
        //res.status(201).json({ message: 'Registrasi berhasil', user: result.rows[0] });
        res.send('<script>window.location.href = "/login";</script>');
        //res.redirect('/login');
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat melakukan registrasi' });
    }
});


// Rute untuk login pengguna
app.post('/api/login', async (req, res) => {
    try {
        const { identifier, password } = req.body;

        // Cari pengguna berdasarkan email atau username
        const result = await pool.query('SELECT * FROM user_table WHERE email = $1 OR username = $1', [identifier]);
        const userDB = result.rows[0];

        // Cek apakah pengguna ditemukan
        if (!userDB) {
            console.log("Pengguna tidak ditemukan");
            return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
        }

        // Verifikasi password
        if (password !== userDB.password) {
            console.log("Password salah");
            return res.status(401).json({ message: 'Password salah' });
        }

        // Simpan data pengguna yang berhasil login dalam session
        req.session.user = userDB;

        // Mengirimkan respons berhasil
        res.status(200).json({ message: 'Login berhasil', user: userDB });
        console.log(req.session.user);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat melakukan login' });
    }
});

//Rute untuk menampilkan profile pengguna
app.get('/api/user', (req, res) => {
    const userId = req.session.userId;

    // Ambil informasi pengguna dari database berdasarkan userId
    const getUserQuery = 'SELECT * FROM user_table WHERE id = $1';
    pool.query(getUserQuery, [userId], (error, result) => {
        if (error) {
            console.error('Error:', error);
            res.status(500).json({ message: 'Terjadi kesalahan saat mengambil informasi pengguna' });
        } else {
            const userDB = result.rows[0];

            if (userDB) {
                // Kirim informasi pengguna yang sedang login sebagai respons
                res.status(200).json({ username: userDB.username, role: userDB.role });
            } else {
                res.status(404).json({ message: 'Pengguna tidak ditemukan' });
            }
        }
    });
});

//Rute untuk menambahkan data profile
app.post('/api/profile', async (req, res) => {
    try {
        const { name, role, partnerID, vehicleLicense, npm, alamat, phoneNumber } = req.body;

        // Lakukan validasi data jika diperlukan

        // Simpan data ke dalam database
        const result = await pool.query(
            'INSERT INTO user_table  (name, role, partnerID, vehicleLicense, npm, alamat, phoneNumber) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
            [name, role, partnerID, vehicleLicense, npm, alamat, phoneNumber]
        );
        const savedData = result.rows[0];

        // Mengirimkan respons berhasil
        res.json({ message: 'Data berhasil disimpan', data: savedData });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menyimpan data' });
    }
});

app.post('/api/topup', async (req, res) => {
    const userId = req.session.userId;
    const { amount } = req.body;

    try {
        // Perbarui saldo pengguna di dalam tabel user_table
        const updateQuery = 'UPDATE user_table SET balance = balance + $1 WHERE id = $2';
        await pool.query(updateQuery, [amount, userId]);

        // Ambil data pengguna terbaru setelah perubahan saldo
        const getUserQuery = 'SELECT * FROM user_table WHERE id = $1';
        const result = await pool.query(getUserQuery, [userId]);
        const userDB = result.rows[0];

        if (userDB) {
            // Kirim respons berhasil dengan data saldo terbaru
            res.status(200).json({ message: 'Top-up berhasil', balance: userDB.balance });
        } else {
            // Kirim respons gagal jika pengguna tidak ditemukan
            res.status(404).json({ message: 'Pengguna tidak ditemukan' });
        }
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui saldo pengguna' });
    }
});

//API untuk update user
app.put('/api/users/:id', async (req, res) => {
    const { id } = req.params;
    const { nama, alamat, phone_number, npm, vehicle_license } = req.body;

    try {
        // Cek apakah pengguna dengan ID yang diberikan ada di database
        const user_table = await pool.query('SELECT * FROM user_table  WHERE user_id = $1', [id]);
        if (user.rows.length === 0) {
            return res.status(404).json({ message: 'Pengguna tidak ditemukan' });
        }

        // Update data pengguna
        const result = await pool.query(
            'UPDATE user_table  SET nama = $1, alamat = $2, phone_number = $3, npm = $4, vehicle_license = $5 WHERE user_id = $6 RETURNING *',
            [nama, alamat, phone_number, npm, vehicle_license, id]
        );

        res.json({ message: 'Data pengguna berhasil diperbarui', user: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui data pengguna' });
    }
});

//Untuk Menambahkan data sepeda
app.post('/api/bikes', async (req, res) => {
    try {
        const { SpekunId, dropLocation, Rider, fuel, status } = req.body;

        // Masukkan data sepeda ke dalam tabel "bikes"
        const result = await pool.query(
            'INSERT INTO bikes (spekun_id, drop_loc, Rider, fuel, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [SpekunId, dropLocation, userId, fuel, status]
        );

        // Mengirimkan respons berhasil dengan data sepeda yang baru ditambahkan
        res.status(201).json({ message: 'Data sepeda berhasil ditambahkan', bike: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan data sepeda' });
    }
});

// Rute untuk logout pengguna
app.get('/api/logout', (req, res) => {
    // Hapus data pengguna dari session
    req.session.destroy((err) => {
        if (err) {
            console.error('Error:', err);
            return res.status(500).json({ message: 'Terjadi kesalahan saat logout' });
        }

        // Mengirimkan respons berhasil
        res.status(200).json({ message: 'Logout berhasil' });
    });
});


// Memulai server
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});

module.exports = app, pool, router;


//ADMIN WISE

//BIKUN_WISE
app.get('/api/Rbikun', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM sched_bikun');
        res.json(result.rows);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengambil data' });
    }
});

app.post('/api/Cbikun', async (req, res) => {
    try {
        const { Plat_nomor, Waktu_berangkat, jalur } = req.body;
        const result = await pool.query(
            'INSERT INTO sched_bikun (Plat_nomor, Waktu_berangkat, jalur) VALUES ($1, $2, $3) RETURNING *',
            [Plat_nomor, Waktu_berangkat, jalur]
        );
        res.status(201).json({ message: 'Data berhasil ditambahkan', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan data' });
    }
});

app.delete('/api/Dbikun/:Plat_nomor', async (req, res) => {
    const { Plat_nomor } = req.params;
    try {
        const result = await pool.query('DELETE FROM sched_bikun WHERE Plat_nomor = $1', [Plat_nomor]);
        res.json({ message: 'Data berhasil dihapus' });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus data' });
    }
});

app.put('/api/Ubikun/:Plat_nomor', async (req, res) => {
    const { Plat_nomor } = req.params;
    const { Waktu_berangkat, jalur } = req.body;

    try {
        // Periksa apakah Plat_nomor ada di tabel sched_bikun
        const checkData = await pool.query('SELECT * FROM sched_bikun WHERE Plat_nomor = $1', [Plat_nomor]);
        if (checkData.rows.length === 0) {
            return res.status(404).json({ message: 'Data tidak ditemukan' });
        }

        // Update data
        const result = await pool.query(
            'UPDATE sched_bikun SET Waktu_berangkat = $1, jalur = $2 WHERE Plat_nomor = $3 RETURNING *',
            [Waktu_berangkat, jalur, Plat_nomor]
        );

        res.json({ message: 'Data berhasil diperbarui', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui data' });
    }
});

//KRL WISE
// Mendapatkan seluruh data pada tabel Sched_KRL
app.get('/api/RKRL', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Sched_KRL');
        res.json(result.rows);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat membaca data Sched_KRL' });
    }
});

// Menghapus data pada tabel Sched_KRL berdasarkan Kode_kereta
app.delete('/api/DKRL/:Kode_kereta', async (req, res) => {
    const { Kode_kereta } = req.params;

    try {
        const result = await pool.query('DELETE FROM Sched_KRL WHERE Kode_kereta = $1 RETURNING *', [Kode_kereta]);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Data Sched_KRL tidak ditemukan' });
        }
        res.json({ message: 'Data Sched_KRL berhasil dihapus', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus data Sched_KRL' });
    }
});

// Menambahkan data ke tabel Sched_KRL
app.post('/api/CKRL', async (req, res) => {
    const { Kode_kereta, Jam_tiba, Stamformasi, Tujuan } = req.body;

    try {
        const result = await pool.query(
            'INSERT INTO Sched_KRL (Kode_kereta, Jam_tiba, Stamformasi, Tujuan) VALUES ($1, $2, $3, $4) RETURNING *',
            [Kode_kereta, Jam_tiba, Stamformasi, Tujuan]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan data ke Sched_KRL' });
    }
});

// Mengupdate data pada tabel Sched_KRL berdasarkan Kode_kereta
app.put('/api/UKRL/:Kode_kereta', async (req, res) => {
    const { Kode_kereta } = req.params;
    const { Jam_tiba, Stamformasi, Tujuan } = req.body;

    try {
        const result = await pool.query(
            'UPDATE Sched_KRL SET Jam_tiba = $1, Stamformasi = $2, Tujuan = $3 WHERE Kode_kereta = $4 RETURNING *',
            [Jam_tiba, Stamformasi, Tujuan, Kode_kereta]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Data Sched_KRL tidak ditemukan' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengupdate data Sched_KRL' });
    }
});


//WISE Spekun
app.post('/api/spekun', async (req, res) => {
    try {
        const { spekun_id, Rider, drop_loc, fuel, status } = req.body;

        // Insert data ke tabel Spekun
        const result = await pool.query(
            'INSERT INTO spekun (spekun_id, Rider, drop_loc, fuel, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [spekun_id, Rider, drop_loc, fuel, status]
        );

        res.status(201).json({ message: 'Data Spekun berhasil ditambahkan', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menambahkan data Spekun' });
    }
});


app.get('/api/spekun', async (req, res) => {
    try {
        // Ambil semua data dari tabel Spekun
        const result = await pool.query('SELECT * FROM spekun');
        res.json(result.rows);
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat mengambil data Spekun' });
    }
});

app.put('/api/spekun/:id', async (req, res) => {
    const { id } = req.params;
    const { Rider, drop_loc, fuel, status } = req.body;

    try {
        // Cek apakah data Spekun dengan ID yang diberikan ada di database
        const spekun = await pool.query('SELECT * FROM spekun WHERE spekun_id = $1', [id]);
        if (spekun.rows.length === 0) {
            return res.status(404).json({ message: 'Data Spekun tidak ditemukan' });
        }

        // Update data Spekun
        const result = await pool.query(
            'UPDATE spekun SET Rider = $1, drop_loc = $2, fuel = $3, status = $4 WHERE spekun_id = $5 RETURNING *',
            [Rider, drop_loc, fuel, status, id]
        );

        res.json({ message: 'Data Spekun berhasil diperbarui', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat memperbarui data Spekun' });
    }
});


app.delete('/api/spekun/:id', async (req, res) => {
    const { id } = req.params;

    try {
        // Cek apakah data Spekun dengan ID yang diberikan ada di database
        const spekun = await pool.query('SELECT * FROM spekun WHERE spekun_id = $1', [id]);
        if (spekun.rows.length === 0) {
            return res.status(404).json({ message: 'Data Spekun tidak ditemukan' });
        }

        // Hapus data Spekun
        await pool.query('DELETE FROM spekun WHERE spekun_id = $1', [id]);

        res.json({ message: 'Data Spekun berhasil dihapus' });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'Terjadi kesalahan saat menghapus data Spekun' });
    }
});

app.post('/api/drop_point', async (req, res) => {
    try {
        const { location, charger_point, park_point, bus_stop } = req.body;

        // Insert data into drop_point table
        const result = await pool.query(
            'INSERT INTO drop_point (location, charger_point, park_point, bus_stop) VALUES ($1, $2, $3, $4) RETURNING *',
            [location, charger_point, park_point, bus_stop]
        );

        res.status(201).json({ message: 'Drop point data created successfully', data: result.rows[0] });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'An error occurred while creating drop point data' });
    }
});

// Get all drop points
app.get('/api/drop_point', async (req, res) => {
    try {
        // Retrieve all data from drop_point table
        const result = await pool.query('SELECT * FROM drop_point');

        res.status(200).json({ data: result.rows });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'An error occurred while retrieving drop point data' });
    }
});

// Update a drop point
app.put('/api/drop_point/:drop_id', async (req, res) => {
    try {
        const dropId = req.params.drop_id;
        const { location, charger_point, park_point, bus_stop } = req.body;

        // Update data in drop_point table
        const result = await pool.query(
            'UPDATE drop_point SET location = $1, charger_point = $2, park_point = $3, bus_stop = $4 WHERE drop_id = $5 RETURNING *',
            [location, charger_point, park_point, bus_stop, dropId]
        );

        if (result.rows.length === 0) {
            res.status(404).json({ message: 'Drop point data not found' });
        } else {
            res.status(200).json({ message: 'Drop point data updated successfully', data: result.rows[0] });
        }
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'An error occurred while updating drop point data' });
    }
});

// Delete a drop point
app.delete('/api/drop_point/:drop_id', async (req, res) => {
    try {
        const dropId = req.params.drop_id;

        // Delete data from drop_point table
        const result = await pool.query('DELETE FROM drop_point WHERE drop_id = $1 RETURNING *', [dropId]);

        if (result.rows.length === 0) {
            res.status(404).json({ message: 'Drop point data not found' });
        } else {
            res.status(200).json({ message: 'Drop point data deleted successfully', data: result.rows[0] });
        }
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ message: 'An error occurred while deleting drop point data' });
    }
});
