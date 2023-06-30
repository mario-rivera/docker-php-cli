# How to build the image

## For development

```
docker build --target development -t mariort/phpcli:{versionnumber}-dev .
```

## For production

```
docker build --target production -t mariort/phpcli:{versionnumber} .