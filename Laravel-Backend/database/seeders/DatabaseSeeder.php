<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Artikel;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ── ADMIN ────────────────────────────────────────
        $admin = User::firstOrCreate(
            ['email' => 'admin@gmail.com'],
            [
                'nama'     => 'Admin DiabTrack',
                'name'     => 'Admin DiabTrack',
                'email'    => 'admin@gmail.com',
                'password' => Hash::make('123456'),
                'role'     => 'admin',
            ]
        );

        // ── PASIEN DUMMY ─────────────────────────────────
        User::firstOrCreate(
            ['email' => 'user@gmail.com'],
            [
                'nama'     => 'User Test',
                'name'     => 'User Test',
                'email'    => 'user@gmail.com',
                'password' => Hash::make('123456'),
                'role'     => 'pasien',
            ]
        );

        // ── ARTIKEL DUMMY ─────────────────────────────────
        $daftarArtikel = [
            [
                'judul'        => 'Apa itu Diabetes?',
                'kategori'     => 'Dasar',
                'is_published' => true,
                'views'        => 320,
                'isi'          => "Diabetes adalah kondisi ketika kadar gula dalam darah terlalu tinggi karena tubuh tidak memproduksi atau menggunakan insulin dengan baik.\n\nAda dua tipe utama:\n• Tipe 1: Tubuh tidak memproduksi insulin sama sekali\n• Tipe 2: Tubuh tidak menggunakan insulin secara efektif\n\nGejala umum meliputi sering haus, sering buang air kecil, mudah lelah, dan penglihatan kabur.",
            ],
            [
                'judul'        => 'Diet Seimbang untuk Penderita Diabetes Tipe 2',
                'kategori'     => 'Nutrisi',
                'is_published' => true,
                'views'        => 980,
                'isi'          => "Mengatur pola makan yang tepat adalah kunci utama dalam mengelola diabetes tipe 2.\n\nPilih karbohidrat kompleks seperti nasi merah, oatmeal, dan ubi. Hindari gula tambahan dan minuman manis.\n\nKonsumsi protein tanpa lemak seperti ikan, ayam tanpa kulit, dan tahu tempe. Perbanyak sayuran hijau dan buah rendah gula seperti apel dan pir.",
            ],
            [
                'judul'        => 'Pentingnya Cek Gula Darah Rutin',
                'kategori'     => 'Monitoring',
                'is_published' => true,
                'views'        => 540,
                'isi'          => "Memantau gula darah secara rutin membantu mencegah komplikasi serius.\n\nTarget gula darah normal:\n• Puasa: 80–130 mg/dL\n• 2 jam setelah makan: < 180 mg/dL\n• HbA1c: < 7%\n\nWaktu terbaik cek gula darah:\n• Pagi sebelum makan\n• 2 jam setelah makan\n• Sebelum tidur",
            ],
            [
                'judul'        => 'Olahraga Ringan yang Aman untuk Penderita Diabetes',
                'kategori'     => 'Gaya Hidup',
                'is_published' => true,
                'views'        => 750,
                'isi'          => "Aktivitas fisik membantu tubuh menggunakan insulin lebih efektif.\n\nOlahraga yang dianjurkan:\n• Jalan kaki 30 menit sehari\n• Bersepeda santai\n• Renang\n• Yoga atau senam ringan\n\nPanduan penting:\n⚠️ Cek gula darah sebelum dan sesudah olahraga\n⚠️ Bawa camilan jika gula darah < 100 mg/dL",
            ],
            [
                'judul'        => 'Mengenal Indeks Glikemik Makanan',
                'kategori'     => 'Nutrisi',
                'is_published' => false,
                'views'        => 0,
                'isi'          => "Indeks Glikemik (IG) mengukur seberapa cepat makanan meningkatkan gula darah.\n\nKategori IG:\n• IG Rendah (< 55): Aman — nasi merah, ubi, apel\n• IG Sedang (55-70): Hati-hati — roti gandum, pisang\n• IG Tinggi (> 70): Hindari — nasi putih, roti putih",
            ],
        ];

        foreach ($daftarArtikel as $data) {
            Artikel::firstOrCreate(
                ['judul' => $data['judul']],
                array_merge($data, ['admin_id' => $admin->id])
            );
        }

        $this->command->info('✅ Seeder selesai!');
        $this->command->info('   Admin : admin@gmail.com / 123456');
        $this->command->info('   Pasien: user@gmail.com / 123456');
    }
}
