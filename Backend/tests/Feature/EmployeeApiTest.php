<?php

namespace Tests\Feature;

use App\Models\Employee;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EmployeeApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_lists_employees_with_flagging_fields(): void
    {
        Employee::create([
            'name' => 'Flagged Employee',
            'email' => 'flagged@example.com',
            'department' => 'Engineering',
            'designation' => 'Senior Dev',
            'joining_date' => Carbon::today()->subYears(7),
            'is_active' => true,
        ]);

        Employee::create([
            'name' => 'New Hire',
            'email' => 'new@example.com',
            'department' => 'HR',
            'designation' => 'Junior',
            'joining_date' => Carbon::today()->subYears(2),
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/employees');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    ['id', 'name', 'is_active', 'years_of_service', 'is_flagged'],
                ],
                'meta' => ['current_page', 'last_page', 'total'],
            ]);

        $flagged = collect($response->json('data'))->firstWhere('email', 'flagged@example.com');
        $this->assertTrue($flagged['is_flagged']);
        $this->assertGreaterThan(5, $flagged['years_of_service']);

        $newHire = collect($response->json('data'))->firstWhere('email', 'new@example.com');
        $this->assertFalse($newHire['is_flagged']);
    }

    public function test_inactive_veteran_is_not_flagged(): void
    {
        Employee::create([
            'name' => 'Inactive Veteran',
            'email' => 'inactive@example.com',
            'department' => 'Finance',
            'designation' => 'Manager',
            'joining_date' => Carbon::today()->subYears(10),
            'is_active' => false,
        ]);

        $response = $this->getJson('/api/employees');

        $employee = collect($response->json('data'))->firstWhere('email', 'inactive@example.com');
        $this->assertFalse($employee['is_flagged']);
    }

    public function test_search_filters_by_name(): void
    {
        Employee::create([
            'name' => 'Alice Wonder',
            'email' => 'alice@example.com',
            'department' => 'Marketing',
            'designation' => 'Lead',
            'joining_date' => '2020-01-01',
            'is_active' => true,
        ]);

        Employee::create([
            'name' => 'Bob Builder',
            'email' => 'bob@example.com',
            'department' => 'Sales',
            'designation' => 'Rep',
            'joining_date' => '2021-01-01',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/employees?search=Alice');

        $response->assertOk();
        $this->assertCount(1, $response->json('data'));
        $this->assertSame('Alice Wonder', $response->json('data.0.name'));
    }

    public function test_stats_endpoint_returns_counts(): void
    {
        Employee::create([
            'name' => 'A',
            'email' => 'a@example.com',
            'department' => 'Eng',
            'designation' => 'Dev',
            'joining_date' => Carbon::today()->subYears(8),
            'is_active' => true,
        ]);

        Employee::create([
            'name' => 'B',
            'email' => 'b@example.com',
            'department' => 'HR',
            'designation' => 'HR',
            'joining_date' => Carbon::today()->subYears(1),
            'is_active' => false,
        ]);

        $response = $this->getJson('/api/employees/stats');

        $response->assertOk()
            ->assertJson([
                'total' => 2,
                'active' => 1,
                'flagged' => 1,
            ]);
    }

    public function test_can_create_update_and_delete_employee(): void
    {
        $create = $this->postJson('/api/employees', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'department' => 'Ops',
            'designation' => 'Analyst',
            'joining_date' => '2024-06-01',
            'is_active' => true,
        ]);

        $create->assertCreated();
        $id = $create->json('data.id');

        $this->putJson("/api/employees/{$id}", [
            'designation' => 'Senior Analyst',
        ])->assertOk()
            ->assertJsonPath('data.designation', 'Senior Analyst');

        $this->deleteJson("/api/employees/{$id}")->assertNoContent();

        $this->getJson("/api/employees/{$id}")->assertNotFound();
    }
}
