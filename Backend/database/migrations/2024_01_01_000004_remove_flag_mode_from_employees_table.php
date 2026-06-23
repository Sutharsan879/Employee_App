<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('employees', 'flag_mode')) {
            Schema::table('employees', function (Blueprint $table) {
                $table->dropColumn('flag_mode');
            });
        }
    }

    public function down(): void
    {
        if (! Schema::hasColumn('employees', 'flag_mode')) {
            Schema::table('employees', function (Blueprint $table) {
                $table->string('flag_mode', 10)->default('auto')->after('is_active');
            });
        }
    }
};
