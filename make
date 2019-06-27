#!/usr/bin/env php
<?php declare(strict_types=1);

include_once("vendor/autoload.php");

$composer = json_decode(file_get_contents('composer.json'), true);
if (isset($composer['autoload']['psr-4'])) {
    $autoloadClasses = $composer['autoload']['psr-4'];
}

if (!isset($autoloadClasses) || empty($autoloadClasses)) {
    echo sprintf("  ❌  Unable to find autoload namespaces from composer.json; please add there first, then try again\n");
    exit(1);
}

if (! isset($argv[1])) {
    echo instructions();
}

switch ($argv[1]) {
    case 'project':
        echo "\n";
        echo "Which project do you want to create?\n";
        $projectClasses = array_values($autoloadClasses);
        foreach($projectClasses as $k => $path) {
            echo sprintf("  [%d] %s\n", ($k + 1), rtrim($path, '/'));
        }
        $project = readline("\nSelect project, or 0 to cancel: ");
        if (!$project) {
            echo "\n";
            exit(0);
        }
        if (!isset($projectClasses[$project - 1])) {
            echo sprintf("  ❌  '%d' is not a valid option.\n\n", $project);
            exit(1);
        }
        $project = rtrim($projectClasses[$project - 1], '/');
        if (file_exists($project)) {
            echo sprintf("  ❌  A project/directory called '%s' already exists.\n\n", $project);
            exit(1);
        }
        echo "\n";
        echo sprintf("   Creating:\n");
        echo sprintf("   -  %s/Controllers/Index.php\n", $project);
        echo sprintf("   -  %s/Models/Index.php\n", $project);
        echo sprintf("   -  %s/Views/Index/default.twig.html\n", $project);
        echo "\n";
        $okay = readline('Proceed (Y/n)? ');
        if (trim(strtoupper($okay)) != 'Y') {
            echo "\n";
            exit(0);
        }
        $namespace = rtrim(array_search($project . '/', $autoloadClasses), '\\');
        createProject($project, $namespace);
        break;

    case 'controller':
        echo "\n";
        echo "Which project do you want to create a controller in?\n";
        $projectClasses = array_values($autoloadClasses);
        foreach($projectClasses as $k => $path) {
            echo sprintf("  [%d] %s\n", ($k + 1), rtrim($path, '/'));
        }
        $project = readline("\nSelect project, or 0 to cancel: ");
        if (!$project) {
            echo "\n";
            exit(0);
        }
        if (!isset($projectClasses[$project - 1])) {
            echo sprintf("  ❌  '%d' is not a valid option.\n\n", $project);
            exit(1);
        }
        $project = rtrim($projectClasses[$project - 1], '/');
        if (!file_exists($project)) {
            echo sprintf("  ❌  A project directory called '%s' does not exist. Use `make project` to create it first.\n\n", $project);
            exit(1);
        }
        $controller = readline("\nName of controller (or blank to cancel): ");
        if (!$controller) {
            echo "\n";
            exit(0);
        }
        $controller = trim(ucfirst($controller));
        echo "\n";
        echo sprintf("   Creating:\n");
        echo sprintf("   -  %s/Controllers/%s.php\n", $project, $controller);
        echo sprintf("   -  %s/Models/%s.php\n", $project, $controller);
        echo sprintf("   -  %s/Views/%s/default.html.twig\n", $project, $controller);
        echo "\n";
        $okay = readline('Proceed (Y/n)? ');
        if (trim(strtoupper($okay)) != 'Y') {
            echo "\n";
            exit(0);
        }
        $namespace = rtrim(array_search($project . '/', $autoloadClasses), '\\');
        createController($project, $namespace, $controller);
        break;

    default:
        instructions();
        break;
}

function instructions()
{
    echo "      Usage: ./make <thing>\n";
    echo "             <thing> what thing you want to create:\n";
    echo "             - project\n";
    echo "             - index\n";
    echo "             - controller\n";
    echo "\n";
    exit(1);
}

function createProject(string $project, string $namespace): void
{

    mkdir($project);
    mkdir($project . '/Controllers');
    mkdir($project . '/Models');
    mkdir($project . '/Views');

    createController($project, $namespace, 'Index');

}

function createController(string $project, string $namespace, string $controller): void
{

    mkdir($project . '/Views/' . $controller);

    echo "\n";

    if (!file_exists($project . '/Controllers/' . $controller . '.php')) {
        file_put_contents($project . '/Controllers/' . $controller . '.php', getController($namespace, $controller));
        echo sprintf("  ✅  Created %s/Controllers/%s.php\n", $project, $controller);
    }

    if (!file_exists($project . '/Models/' . $controller . '.php')) {
        file_put_contents($project . '/Models/' . $controller . '.php', getModel($namespace, $controller));
        echo sprintf("  ✅  Created %s/Models/%s.php\n", $project, $controller);
    }

    if (!file_exists($project . '/Views/base.html.twig')) {
        file_put_contents($project . '/Views/base.html.twig', getViewBase());
        echo sprintf("  ✅  Created %s/Views/base.html.twig\n", $project, $controller);
    }

    if (!file_exists($project . '/Views/' . $controller . '/default.html.twig')) {
        file_put_contents($project . '/Views/' . $controller . '/default.html.twig', getView());
        echo sprintf("  ✅  Created %s/Views/%s/default.html.twig\n", $project, $controller);
    }

    echo "\n";

}

function getController(string $namespace, string $controller): string
{
    return <<<EOT
<?php declare(strict_types=1);

namespace $namespace\Controllers;

use Yurly\Core\{Project, Controller};
use Yurly\Inject\Request\Get;
use Yurly\Inject\Response\Twig;
use $namespace\Models\\$controller as Model;

class $controller extends Controller
{

    private \$model;

    public function __construct(Project \$project)
    {
        \$this->model = new Model(\$project);
    }

    public function routeDefault(Get \$request, Twig \$response): array
    {
        return \$this->model->default(\$request);
    }

}
EOT;
}

function getModel(string $namespace, string $controller): string
{
    return <<<EOT
<?php declare(strict_types=1);

namespace $namespace\Models;

use Yurly\Core\Project;
use Yurly\Core\Inject\Request;

class $controller extends Controller
{

    private \$project;

    public function __construct(Project \$project)
    {
        \$this->project = \$project;
    }

    public function default(Request \$request): array
    {
        return [
            'title'   => '$controller',
            'content' => sprintf('Hello, %s!', \$request->name ?? 'world')
        ];
    }

}
EOT;
}

function getViewBase(): string
{
    return <<<EOT
<html>
    <head>
        <title>{% block title %}Title{% endblock %}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
    </head>

    <body>
        {% block content %}{% endblock %}
    </body>
</html>
EOT;
}

function getView(): string
{
    return <<<EOT
{% extends "base.html.twig" %}

{% block title %}{{ title }}{% endblock %}
{% block content %}

    <h1>{{ title }}</h1>
    <div>{{ content }}</div>

{% endblock %}
EOT;
}