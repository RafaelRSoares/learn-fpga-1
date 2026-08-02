package project.src.java.core.parsers.dotTreeParser;

import project.src.java.core.parsers.dotTreeParser.treeStructure.Tree;
import project.src.java.core.parsers.dotTreeParser.treeStructure.TreeBuilder;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Parser {

    public static List<String> featuresNames;
    public static Set<String> classesNames;

    public static List<Tree> execute(String dataset) throws IOException {
        readDatasetHeader(dataset);
        System.out.println(classesNames);
        System.out.println(featuresNames);
        return readDatasetSamples(dataset);
    }

    public static int getClassQuantity(){
        return classesNames.size();
    }

    public static int getFeatureQuantity(){

        /* the number of feature also count the class column, subtracting 1 to return the correct value */

        return featuresNames.size();
    }

    private static void readDatasetHeader(String dataset) throws IOException {
        var path = System.getProperty("user.dir")
            + "/datasets/"
            + dataset;

        var scanner = new Scanner(new File(path));

        String[] header = scanner.nextLine().split(",");

        int labelIndex = -1;
        featuresNames = new ArrayList<>();

        for (int index = 0; index < header.length; index++) {
            if (header[index].equals("label")) {
                labelIndex = index;
            } else {
                featuresNames.add(header[index]);
            }
        }

        if (labelIndex < 0) {
            scanner.close();
            throw new IOException(
                "A coluna 'label' não foi encontrada no dataset."
            );
        }

        // Ordena numericamente as classes: 0, 1, 2 e 3.
        classesNames = new TreeSet<>(
            Comparator.comparingInt(Integer::parseInt)
        );

        while (scanner.hasNextLine()) {
            String[] values = scanner.nextLine().split(",");

            if (values.length == header.length) {
                classesNames.add(values[labelIndex]);
            }
        }

        scanner.close();
    }

    private static List<Tree> readDatasetSamples(String dataset) throws IOException {
        var path = System.getProperty("user.dir") + "/trees/" + dataset;
        var files = listFiles(path);
        var a = files
                .stream()
                .sorted()
                .map(file -> parseFromDot(path, file))
                .collect(Collectors.toList());
        return a;
    }

    private static Tree parseFromDot(String path, String file) {
        try {
            return TreeBuilder.execute(
                path + "/" + file,
                featuresNames,
                classesNames
            );
        } catch (Exception e) {
            System.err.println(
                "Erro ao processar a árvore " + file + ": "
                + e.getMessage()
            );
            e.printStackTrace();
            return null;
        }
    }

    private static Set<String> listFiles(String path) {
        return Stream.of(new File(path).listFiles())
          .filter(file -> !file.isDirectory())
          .map(File::getName)
          .collect(Collectors.toSet());
    }

}
