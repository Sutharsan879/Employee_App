<?php

namespace Database\Seeders;

use App\Models\Employee;
use Illuminate\Database\Seeder;

class EmployeeSeeder extends Seeder
{
    public function run(): void
    {
        $employees = [
            ['name' => 'John Doe', 'email' => 'john.doe@zylu.com', 'department' => 'Engineering', 'designation' => 'Senior Developer', 'phone' => '+91 9876543210', 'joining_date' => '2017-03-15', 'is_active' => true],
            ['name' => 'Jane Smith', 'email' => 'jane.smith@zylu.com', 'department' => 'HR', 'designation' => 'HR Manager', 'phone' => '+91 9876543211', 'joining_date' => '2016-08-20', 'is_active' => true],
            ['name' => 'Michael Chen', 'email' => 'michael.chen@zylu.com', 'department' => 'Engineering', 'designation' => 'Lead Developer', 'phone' => '+91 9876543212', 'joining_date' => '2015-01-10', 'is_active' => true],
            ['name' => 'Sarah Johnson', 'email' => 'sarah.johnson@zylu.com', 'department' => 'Marketing', 'designation' => 'Marketing Director', 'phone' => '+91 9876543213', 'joining_date' => '2018-06-01', 'is_active' => true],
            ['name' => 'David Wilson', 'email' => 'david.wilson@zylu.com', 'department' => 'Finance', 'designation' => 'Senior Accountant', 'phone' => '+91 9876543214', 'joining_date' => '2017-11-25', 'is_active' => false],
            ['name' => 'Emily Brown', 'email' => 'emily.brown@zylu.com', 'department' => 'Operations', 'designation' => 'Operations Manager', 'phone' => '+91 9876543215', 'joining_date' => '2016-04-18', 'is_active' => true],
            ['name' => 'Robert Taylor', 'email' => 'robert.taylor@zylu.com', 'department' => 'Sales', 'designation' => 'Sales Director', 'phone' => '+91 9876543216', 'joining_date' => '2014-09-05', 'is_active' => true],
            ['name' => 'Lisa Anderson', 'email' => 'lisa.anderson@zylu.com', 'department' => 'Engineering', 'designation' => 'Junior Developer', 'phone' => '+91 9876543217', 'joining_date' => '2022-02-14', 'is_active' => true],
            ['name' => 'James Martinez', 'email' => 'james.martinez@zylu.com', 'department' => 'HR', 'designation' => 'HR Specialist', 'phone' => '+91 9876543218', 'joining_date' => '2020-07-22', 'is_active' => true],
            ['name' => 'Amanda White', 'email' => 'amanda.white@zylu.com', 'department' => 'Marketing', 'designation' => 'Marketing Manager', 'phone' => '+91 9876543219', 'joining_date' => '2017-12-03', 'is_active' => true],
            ['name' => 'Christopher Lee', 'email' => 'christopher.lee@zylu.com', 'department' => 'Finance', 'designation' => 'Finance Director', 'phone' => '+91 9876543220', 'joining_date' => '2015-05-30', 'is_active' => true],
            ['name' => 'Jennifer Garcia', 'email' => 'jennifer.garcia@zylu.com', 'department' => 'Operations', 'designation' => 'Operations Lead', 'phone' => '+91 9876543221', 'joining_date' => '2019-03-12', 'is_active' => false],
            ['name' => 'Daniel Rodriguez', 'email' => 'daniel.rodriguez@zylu.com', 'department' => 'Sales', 'designation' => 'Senior Sales Executive', 'phone' => '+91 9876543222', 'joining_date' => '2018-10-08', 'is_active' => true],
            ['name' => 'Michelle Thomas', 'email' => 'michelle.thomas@zylu.com', 'department' => 'Engineering', 'designation' => 'Mid Developer', 'phone' => '+91 9876543223', 'joining_date' => '2021-01-25', 'is_active' => true],
            ['name' => 'Kevin Harris', 'email' => 'kevin.harris@zylu.com', 'department' => 'Engineering', 'designation' => 'Engineering Manager', 'phone' => '+91 9876543224', 'joining_date' => '2013-07-19', 'is_active' => true],
            ['name' => 'Rachel Clark', 'email' => 'rachel.clark@zylu.com', 'department' => 'HR', 'designation' => 'Junior HR Associate', 'phone' => '+91 9876543225', 'joining_date' => '2023-04-10', 'is_active' => true],
            ['name' => 'Brian Lewis', 'email' => 'brian.lewis@zylu.com', 'department' => 'Marketing', 'designation' => 'Content Strategist', 'phone' => '+91 9876543226', 'joining_date' => '2016-11-14', 'is_active' => true],
            ['name' => 'Nicole Walker', 'email' => 'nicole.walker@zylu.com', 'department' => 'Finance', 'designation' => 'Junior Accountant', 'phone' => '+91 9876543227', 'joining_date' => '2024-01-08', 'is_active' => true],
            ['name' => 'Steven Hall', 'email' => 'steven.hall@zylu.com', 'department' => 'Operations', 'designation' => 'Logistics Coordinator', 'phone' => '+91 9876543228', 'joining_date' => '2017-06-27', 'is_active' => false],
            ['name' => 'Laura Allen', 'email' => 'laura.allen@zylu.com', 'department' => 'Sales', 'designation' => 'Sales Manager', 'phone' => '+91 9876543229', 'joining_date' => '2015-02-11', 'is_active' => true],
            ['name' => 'Mark Young', 'email' => 'mark.young@zylu.com', 'department' => 'Engineering', 'designation' => 'DevOps Engineer', 'phone' => '+91 9876543230', 'joining_date' => '2019-08-16', 'is_active' => true],
            ['name' => 'Patricia King', 'email' => 'patricia.king@zylu.com', 'department' => 'HR', 'designation' => 'Director of HR', 'phone' => '+91 9876543231', 'joining_date' => '2014-12-01', 'is_active' => true],
            ['name' => 'Andrew Scott', 'email' => 'andrew.scott@zylu.com', 'department' => 'Marketing', 'designation' => 'Junior Marketing Associate', 'phone' => '+91 9876543232', 'joining_date' => '2023-09-20', 'is_active' => true],
        ];

        foreach ($employees as $employee) {
            Employee::create($employee);
        }
    }
}
